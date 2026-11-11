import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/core/network/api_exception.dart';
import 'package:vidsell/features/cabinet/repositories/api_wallet_repository.dart';
import 'package:vidsell/features/new_listing/repositories/api_promotion_repository.dart';
import 'package:vidsell/models/enums/payment_method.dart';
import 'package:vidsell/models/enums/promotion_type.dart';
import 'package:vidsell/models/product/promote_request.dart';
import 'package:vidsell/models/wallet/top_up_request.dart';

void main() {
  test('wallet repository uses documented balance and top-up routes', () async {
    final adapter = _WalletPromotionAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api'));
    dio.httpClientAdapter = adapter;
    final client = ApiClient(
      config: const AppConfig(
        apiBaseUrl: 'https://api.example.test/api',
        useMockBackend: false,
      ),
      dio: dio,
    );
    addTearDown(() {
      client.dispose();
      dio.close(force: true);
    });

    final repository = ApiWalletRepository(client);
    final balance = await repository.fetchWallet();
    final transactions = await repository.fetchTransactions();
    final intent = await repository.createTopUpIntent(
      request: TopUpRequest(
        amount: 25,
        paymentMethod: PaymentMethod.fromCode('CARD'),
      ),
    );
    final pending = await repository.fetchTopUpIntent(intent.id);
    final completed = await repository.confirmTopUp(intent.id);

    expect(balance.balance, 12.5);
    expect(balance.currency, 'TRY');
    expect(transactions.single.id, 'transaction-1');
    expect(intent.invoiceNumber, 'INV-123456');
    expect(intent.methodLabel, 'Card');
    expect(intent.statusLabel, 'Pending');
    expect(pending.status, 'PENDING');
    expect(completed.status, 'COMPLETED');

    expect(adapter.requests.map((request) => request.path), [
      '/wallet/balance',
      '/wallet/transactions',
      '/wallet/top-up',
      '/wallet/top-up/intent-1',
      '/wallet/top-up/intent-1/confirm',
    ]);
    expect(adapter.requests[1].queryParameters, {'page': 1, 'size': 20});
    expect(adapter.requests[2].data, {'amount': 25, 'paymentMethod': 'CARD'});
  });

  test(
    'promotion repository loads availability and sends documented body',
    () async {
      final adapter = _WalletPromotionAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api'));
      dio.httpClientAdapter = adapter;
      final client = ApiClient(
        config: const AppConfig(
          apiBaseUrl: 'https://api.example.test/api',
          useMockBackend: false,
        ),
        dio: dio,
      );
      addTearDown(() {
        client.dispose();
        dio.close(force: true);
      });

      final repository = ApiPromotionRepository(client);
      final availability = await repository.fetchAvailability();
      await repository.promoteProduct(
        productId: 'product-1',
        request: const PromoteRequest(
          promotionType: PromotionType.vip,
          days: 30,
        ),
      );
      await repository.promoteProduct(
        productId: 'product-1',
        request: const PromoteRequest(
          promotionType: PromotionType.boost,
          days: 1,
        ),
      );

      expect(availability.freeDailyQuota, 2);
      expect(availability.planFor(PromotionType.boost)?.freeTotal, 3);
      expect(availability.prices, {'VIP': 3, 'PREMIUM': 5, 'BOOST': 1.5});
      expect(adapter.requests[0].path, '/promotions/availability');
      expect(adapter.requests[1].path, '/products/product-1/promote');
      expect(adapter.requests[1].data, {'promotionType': 'VIP', 'days': 30});
      expect(adapter.requests[2].data, {'promotionType': 'BOOST', 'days': 1});
    },
  );

  test(
    'promotion repository preserves insufficient-wallet error code',
    () async {
      final adapter = _WalletPromotionAdapter()..failPromotion = true;
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api'));
      dio.httpClientAdapter = adapter;
      final client = ApiClient(
        config: const AppConfig(
          apiBaseUrl: 'https://api.example.test/api',
          useMockBackend: false,
        ),
        dio: dio,
      );
      addTearDown(() {
        client.dispose();
        dio.close(force: true);
      });

      await expectLater(
        ApiPromotionRepository(client).promoteProduct(
          productId: 'product-1',
          request: const PromoteRequest(
            promotionType: PromotionType.premium,
            days: 30,
          ),
        ),
        throwsA(
          isA<ApiException>().having(
            (error) => error.code,
            'code',
            'ERROR_WALLET_INSUFFICIENT_BALANCE',
          ),
        ),
      );
    },
  );

  test(
    'disabled mock top-up confirmation surfaces backend error code',
    () async {
      final adapter = _WalletPromotionAdapter()..failConfirmation = true;
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api'));
      dio.httpClientAdapter = adapter;
      final client = ApiClient(
        config: const AppConfig(
          apiBaseUrl: 'https://api.example.test/api',
          useMockBackend: false,
        ),
        dio: dio,
      );
      addTearDown(() {
        client.dispose();
        dio.close(force: true);
      });

      await expectLater(
        ApiWalletRepository(client).confirmTopUp('intent-1'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.code,
            'code',
            'ERROR_PAYMENT_MOCK_DISABLED',
          ),
        ),
      );
    },
  );
}

class _WalletPromotionAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  bool failPromotion = false;
  bool failConfirmation = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (failPromotion && options.path.endsWith('/promote')) {
      return _response({
        'status': 400,
        'code': 'ERROR_WALLET_INSUFFICIENT_BALANCE',
        'messageKey': 'errors.wallet.insufficientBalance',
      }, status: 400);
    }
    if (failConfirmation && options.path.endsWith('/confirm')) {
      return _response({
        'status': 400,
        'code': 'ERROR_PAYMENT_MOCK_DISABLED',
        'messageKey': 'errors.payment.mockDisabled',
      }, status: 400);
    }

    final body = switch (options.path) {
      '/wallet/balance' => {'balance': 12.5, 'currency': 'TRY'},
      '/wallet/transactions' => {
        'items': [
          {
            'id': 'transaction-1',
            'amount': 5,
            'type': 'TOP_UP',
            'description': 'Wallet top up',
            'createdAt': '2026-09-21T10:00:00Z',
          },
        ],
        'page': 0,
        'size': 20,
        'totalElements': 1,
        'totalPages': 1,
        'last': true,
      },
      '/i18n/enums' => {
        'paymentMethod': [
          {'code': 'CARD', 'label': 'Card'},
        ],
      },
      '/wallet/top-up' => _intent(status: 'PENDING'),
      '/wallet/top-up/intent-1' => _intent(status: 'PENDING'),
      '/wallet/top-up/intent-1/confirm' => _intent(status: 'COMPLETED'),
      '/promotions/availability' => {
        'currency': 'TRY',
        'resetsAt': '2026-09-22T00:00:00Z',
        'plans': [
          {
            'type': 'BOOST',
            'typeLabel': 'Boost',
            'freeRemaining': 2,
            'freeTotal': 3,
            'price': 1.5,
            'currency': 'TRY',
            'periodEnd': '2026-09-22T00:00:00Z',
          },
          {
            'type': 'VIP',
            'typeLabel': 'VIP',
            'freeRemaining': 0,
            'freeTotal': 0,
            'price': 3,
            'currency': 'TRY',
            'periodEnd': '2026-09-22T00:00:00Z',
          },
          {
            'type': 'PREMIUM',
            'typeLabel': 'Premium',
            'freeRemaining': 0,
            'freeTotal': 0,
            'price': 5,
            'currency': 'TRY',
            'periodEnd': '2026-09-22T00:00:00Z',
          },
        ],
      },
      '/products/product-1/promote' => {'id': 'product-1'},
      _ => <String, dynamic>{},
    };
    return _response(body);
  }

  Map<String, dynamic> _intent({required String status}) => {
    'id': 'intent-1',
    'amount': 25,
    'method': 'CARD',
    'methodLabel': 'Card',
    'status': status,
    'statusLabel': status == 'PENDING' ? 'Pending' : 'Completed',
    'invoiceNo': 'INV-123456',
    'createdAt': '2026-09-21T10:00:00Z',
  };

  ResponseBody _response(Map<String, dynamic> body, {int status = 200}) =>
      ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  @override
  void close({bool force = false}) {}
}
