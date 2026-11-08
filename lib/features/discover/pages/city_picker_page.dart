import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/features/discover/models/city.dart';
import 'package:vidsell/features/discover/repositories/city_repository.dart';

class CityPickerPage extends StatefulWidget {
  final CityRepository? repository;

  const CityPickerPage({super.key, this.repository});

  @override
  State<CityPickerPage> createState() => _CityPickerPageState();
}

class _CityPickerPageState extends State<CityPickerPage> {
  final _searchController = TextEditingController();
  late final CityRepository _cityRepository;
  List<City> _cities = const [];
  List<City> _visibleCities = const [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cityRepository = widget.repository ?? context.read<CityRepository>();
    _searchController.addListener(_filter);
    _loadCities();
  }

  Future<void> _loadCities() async {
    try {
      final cities = await _cityRepository.fetchCities();
      if (!mounted) return;
      setState(() {
        _cities = cities;
        _visibleCities = cities;
        _isLoading = false;
      });
      _filter();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filter() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _visibleCities = _cities
          .where((city) => city.name.toLowerCase().contains(query))
          .toList(growable: false);
    });
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_filter)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: context.goBack,
              ),
              title: Text(
                'Şəhər',
                style: AppTextStyle.primaryText.copyWith(color: Colors.white),
              ),
              centerTitle: true,
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Şəhər ara',
                  hintStyle: const TextStyle(color: AppColor.tertiaryTextColor),
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColor.bgSurfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColor.activeColor),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Xəta baş verdi',
              style: TextStyle(color: Colors.white70, fontSize: 14.sp),
            ),
            SizedBox(height: 8.h),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _loadCities();
              },
              child: const Text('Yenidən yoxla'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: _visibleCities.length,
      separatorBuilder: (_, _) =>
          Divider(color: Colors.white.withValues(alpha: 0.1)),
      itemBuilder: (context, index) {
        final city = _visibleCities[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(city.name, style: const TextStyle(color: Colors.white)),
          trailing: const Icon(Icons.chevron_right, color: Colors.white54),
          onTap: () => context.goBack(city),
        );
      },
    );
  }
}
