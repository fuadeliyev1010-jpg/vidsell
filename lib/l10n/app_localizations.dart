import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while loading this page.'**
  String get appError;

  /// No description provided for @offlineMessage.
  ///
  /// In en, this message translates to:
  /// **'There is no internet connection. Some features may be unavailable.'**
  String get offlineMessage;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageTurkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get languageTurkish;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactUs;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About the app'**
  String get aboutApp;

  /// No description provided for @userAgreement.
  ///
  /// In en, this message translates to:
  /// **'User agreement'**
  String get userAgreement;

  /// No description provided for @rules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get rules;

  /// No description provided for @offerAgreement.
  ///
  /// In en, this message translates to:
  /// **'Offer agreement'**
  String get offerAgreement;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @searchProduct.
  ///
  /// In en, this message translates to:
  /// **'Search for a product or service'**
  String get searchProduct;

  /// No description provided for @searchCategory.
  ///
  /// In en, this message translates to:
  /// **'Search categories'**
  String get searchCategory;

  /// No description provided for @searchCity.
  ///
  /// In en, this message translates to:
  /// **'Search cities'**
  String get searchCity;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @allListings.
  ///
  /// In en, this message translates to:
  /// **'All listings'**
  String get allListings;

  /// No description provided for @showListings.
  ///
  /// In en, this message translates to:
  /// **'Show listings'**
  String get showListings;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load'**
  String get loadFailed;

  /// No description provided for @locationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Location access'**
  String get locationPermissionTitle;

  /// No description provided for @locationPermissionDescription.
  ///
  /// In en, this message translates to:
  /// **'VidSell needs location access to accurately show nearby listings, stores, and search results on the map.'**
  String get locationPermissionDescription;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @newListing.
  ///
  /// In en, this message translates to:
  /// **'New listing'**
  String get newListing;

  /// No description provided for @createListing.
  ///
  /// In en, this message translates to:
  /// **'Post a listing'**
  String get createListing;

  /// No description provided for @myListings.
  ///
  /// In en, this message translates to:
  /// **'My listings'**
  String get myListings;

  /// No description provided for @listingDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get listingDescription;

  /// No description provided for @listingTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get listingTitle;

  /// No description provided for @reportListing.
  ///
  /// In en, this message translates to:
  /// **'Report listing'**
  String get reportListing;

  /// No description provided for @selectReason.
  ///
  /// In en, this message translates to:
  /// **'Select a reason'**
  String get selectReason;

  /// No description provided for @describeReport.
  ///
  /// In en, this message translates to:
  /// **'Describe your report'**
  String get describeReport;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @nameAndSurname.
  ///
  /// In en, this message translates to:
  /// **'First and last name'**
  String get nameAndSurname;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @repeatPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get repeatPassword;

  /// No description provided for @loginOrRegister.
  ///
  /// In en, this message translates to:
  /// **'Log in or create an account'**
  String get loginOrRegister;

  /// No description provided for @phoneOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Phone number or email'**
  String get phoneOrEmail;

  /// No description provided for @verifyIdentity.
  ///
  /// In en, this message translates to:
  /// **'Verify your identity'**
  String get verifyIdentity;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @registerIntro.
  ///
  /// In en, this message translates to:
  /// **'Let\'s create your account'**
  String get registerIntro;

  /// No description provided for @registerDescription.
  ///
  /// In en, this message translates to:
  /// **'Post listings and start buying and selling.'**
  String get registerDescription;

  /// No description provided for @termsLead.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to the'**
  String get termsLead;

  /// No description provided for @termsJoin.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get termsJoin;

  /// No description provided for @termsAccept.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get termsAccept;

  /// No description provided for @searchHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recent searches'**
  String get searchHistoryEmpty;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @savedSearch.
  ///
  /// In en, this message translates to:
  /// **'Saved search'**
  String get savedSearch;

  /// No description provided for @noSavedListings.
  ///
  /// In en, this message translates to:
  /// **'You have no saved listings yet'**
  String get noSavedListings;

  /// No description provided for @noSavedSearches.
  ///
  /// In en, this message translates to:
  /// **'You have no saved searches yet'**
  String get noSavedSearches;

  /// No description provided for @noFollowedStores.
  ///
  /// In en, this message translates to:
  /// **'You are not following any stores yet'**
  String get noFollowedStores;

  /// No description provided for @stores.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get stores;

  /// No description provided for @vipListings.
  ///
  /// In en, this message translates to:
  /// **'VIP listings'**
  String get vipListings;

  /// No description provided for @noMatchingListings.
  ///
  /// In en, this message translates to:
  /// **'No listings match these criteria'**
  String get noMatchingListings;

  /// No description provided for @minimumPriceError.
  ///
  /// In en, this message translates to:
  /// **'The minimum price must be lower than the maximum price'**
  String get minimumPriceError;

  /// No description provided for @mapRouteError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the route'**
  String get mapRouteError;

  /// No description provided for @homeEmpty.
  ///
  /// In en, this message translates to:
  /// **'There are no listings right now'**
  String get homeEmpty;

  /// No description provided for @homeLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load listings'**
  String get homeLoadError;

  /// No description provided for @describePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Describe it...'**
  String get describePlaceholder;

  /// No description provided for @contactSeller.
  ///
  /// In en, this message translates to:
  /// **'Contact the seller'**
  String get contactSeller;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @whatsappMessage.
  ///
  /// In en, this message translates to:
  /// **'Message on WhatsApp'**
  String get whatsappMessage;

  /// No description provided for @openDirectChat.
  ///
  /// In en, this message translates to:
  /// **'Open a direct chat'**
  String get openDirectChat;

  /// No description provided for @copyNumber.
  ///
  /// In en, this message translates to:
  /// **'Copy number'**
  String get copyNumber;

  /// No description provided for @inAppMessage.
  ///
  /// In en, this message translates to:
  /// **'Send a message in the app'**
  String get inAppMessage;

  /// No description provided for @chatWithVidsell.
  ///
  /// In en, this message translates to:
  /// **'Contact the seller through VidSell chat'**
  String get chatWithVidsell;

  /// No description provided for @whatsappUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not open WhatsApp'**
  String get whatsappUnavailable;

  /// No description provided for @mapUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not open the maps app'**
  String get mapUnavailable;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// No description provided for @linkCopiedInstagram.
  ///
  /// In en, this message translates to:
  /// **'Link copied. You can share it on Instagram.'**
  String get linkCopiedInstagram;

  /// No description provided for @appCouldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Could not open the app'**
  String get appCouldNotOpen;

  /// No description provided for @storeAddress.
  ///
  /// In en, this message translates to:
  /// **'Store address'**
  String get storeAddress;

  /// No description provided for @navigateGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'Get directions in Google Maps'**
  String get navigateGoogleMaps;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @deleteSelectedMessages.
  ///
  /// In en, this message translates to:
  /// **'Delete the selected messages?'**
  String get deleteSelectedMessages;

  /// No description provided for @deleteConversation.
  ///
  /// In en, this message translates to:
  /// **'Delete this conversation?'**
  String get deleteConversation;

  /// No description provided for @messagesDeletedPermanently.
  ///
  /// In en, this message translates to:
  /// **'All messages will be permanently deleted.'**
  String get messagesDeletedPermanently;

  /// No description provided for @reportUser.
  ///
  /// In en, this message translates to:
  /// **'Report user'**
  String get reportUser;

  /// No description provided for @actionNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'This action is not available yet.'**
  String get actionNotAvailable;

  /// No description provided for @conversationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Delete conversation'**
  String get conversationDeleted;

  /// No description provided for @aboutListing.
  ///
  /// In en, this message translates to:
  /// **'About the listing'**
  String get aboutListing;

  /// No description provided for @deletedMessage.
  ///
  /// In en, this message translates to:
  /// **'You deleted this message'**
  String get deletedMessage;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get pleaseWait;

  /// No description provided for @boostListing.
  ///
  /// In en, this message translates to:
  /// **'Boost listing'**
  String get boostListing;

  /// No description provided for @vipActivate.
  ///
  /// In en, this message translates to:
  /// **'VIP service activated for free.'**
  String get vipActivate;

  /// No description provided for @boostActivate.
  ///
  /// In en, this message translates to:
  /// **'Boost service activated for free.'**
  String get boostActivate;

  /// No description provided for @paymentUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The payment service is not available yet.'**
  String get paymentUnavailable;

  /// No description provided for @premiumActivate.
  ///
  /// In en, this message translates to:
  /// **'Premium service activated for free.'**
  String get premiumActivate;

  /// No description provided for @videoAdd.
  ///
  /// In en, this message translates to:
  /// **'Add a video'**
  String get videoAdd;

  /// No description provided for @videoAddHint.
  ///
  /// In en, this message translates to:
  /// **'Add a short video in 9:16 format'**
  String get videoAddHint;

  /// No description provided for @videoFrameError.
  ///
  /// In en, this message translates to:
  /// **'Could not create a video frame: {error}'**
  String videoFrameError(Object error);

  /// No description provided for @videoOnlyOne.
  ///
  /// In en, this message translates to:
  /// **'You can add only one video.'**
  String get videoOnlyOne;

  /// No description provided for @videoAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not add the video.'**
  String get videoAddFailed;

  /// No description provided for @listingSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Listing submitted'**
  String get listingSubmitted;

  /// No description provided for @listingModeration.
  ///
  /// In en, this message translates to:
  /// **'Your listing was sent for review.'**
  String get listingModeration;

  /// No description provided for @listingWillPublish.
  ///
  /// In en, this message translates to:
  /// **'Your listing will be published after it has been reviewed.'**
  String get listingWillPublish;

  /// No description provided for @freeServicesMonthly.
  ///
  /// In en, this message translates to:
  /// **'Free services (per month)'**
  String get freeServicesMonthly;

  /// No description provided for @freeListingLimit.
  ///
  /// In en, this message translates to:
  /// **'Free listing limit · this month'**
  String get freeListingLimit;

  /// No description provided for @postOnly.
  ///
  /// In en, this message translates to:
  /// **'Post only'**
  String get postOnly;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @vip.
  ///
  /// In en, this message translates to:
  /// **'VIP'**
  String get vip;

  /// No description provided for @boost.
  ///
  /// In en, this message translates to:
  /// **'Boost'**
  String get boost;

  /// No description provided for @included.
  ///
  /// In en, this message translates to:
  /// **'Included'**
  String get included;

  /// No description provided for @accountDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get accountDelete;

  /// No description provided for @accountDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete the store account?'**
  String get accountDeleteConfirm;

  /// No description provided for @storeDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete store'**
  String get storeDelete;

  /// No description provided for @storeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Store editing is not supported yet.'**
  String get storeUnavailable;

  /// No description provided for @profileViews.
  ///
  /// In en, this message translates to:
  /// **'Profile views'**
  String get profileViews;

  /// No description provided for @howOthersSeeProfile.
  ///
  /// In en, this message translates to:
  /// **'See how other users view your profile'**
  String get howOthersSeeProfile;

  /// No description provided for @socialLinks.
  ///
  /// In en, this message translates to:
  /// **'Social media links'**
  String get socialLinks;

  /// No description provided for @additionalPhone.
  ///
  /// In en, this message translates to:
  /// **'Additional phone'**
  String get additionalPhone;

  /// No description provided for @workHours.
  ///
  /// In en, this message translates to:
  /// **'Working hours'**
  String get workHours;

  /// No description provided for @photoGallery.
  ///
  /// In en, this message translates to:
  /// **'Photo gallery'**
  String get photoGallery;

  /// No description provided for @welcomeMessages.
  ///
  /// In en, this message translates to:
  /// **'Welcome messages'**
  String get welcomeMessages;

  /// No description provided for @greetNewCustomers.
  ///
  /// In en, this message translates to:
  /// **'Automatically greet new customers'**
  String get greetNewCustomers;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @profilePhotoDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete profile photo?'**
  String get profilePhotoDelete;

  /// No description provided for @profilePhotoDeleteDescription.
  ///
  /// In en, this message translates to:
  /// **'Your profile photo will be deleted. You can add a new photo at any time.'**
  String get profilePhotoDeleteDescription;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @walletBalance.
  ///
  /// In en, this message translates to:
  /// **'Your wallet balance'**
  String get walletBalance;

  /// No description provided for @topUpBalance.
  ///
  /// In en, this message translates to:
  /// **'Top up balance'**
  String get topUpBalance;

  /// No description provided for @amountAzn.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountAzn;

  /// No description provided for @amountRangeError.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount between 1 and 100000 {currency}'**
  String amountRangeError(String currency);

  /// No description provided for @cardholderName.
  ///
  /// In en, this message translates to:
  /// **'First and last name'**
  String get cardholderName;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card number'**
  String get cardNumber;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @cvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cvv;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEdit;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic information'**
  String get basicInfo;

  /// No description provided for @aboutYou.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get aboutYou;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @noCategoryFound.
  ///
  /// In en, this message translates to:
  /// **'No categories found'**
  String get noCategoryFound;

  /// No description provided for @subcategoryNotFound.
  ///
  /// In en, this message translates to:
  /// **'No subcategories found'**
  String get subcategoryNotFound;

  /// No description provided for @storeProfile.
  ///
  /// In en, this message translates to:
  /// **'Store profile'**
  String get storeProfile;

  /// No description provided for @storeSearch.
  ///
  /// In en, this message translates to:
  /// **'Search stores'**
  String get storeSearch;

  /// No description provided for @storeClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get storeClosed;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get showMore;

  /// No description provided for @routeOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the route'**
  String get routeOpenFailed;

  /// No description provided for @contactLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link'**
  String get contactLinkFailed;

  /// No description provided for @questionUnanswered.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t find an answer to your question?'**
  String get questionUnanswered;

  /// No description provided for @callUs.
  ///
  /// In en, this message translates to:
  /// **'Call us'**
  String get callUs;

  /// No description provided for @messageUs.
  ///
  /// In en, this message translates to:
  /// **'Message us'**
  String get messageUs;

  /// No description provided for @profileEditUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Profile editing is not supported yet.'**
  String get profileEditUnavailable;

  /// No description provided for @businessLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your business account'**
  String get businessLogin;

  /// No description provided for @businessAccount.
  ///
  /// In en, this message translates to:
  /// **'Business account'**
  String get businessAccount;

  /// No description provided for @businessNoStore.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have a store'**
  String get businessNoStore;

  /// No description provided for @createStoreDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a dedicated store page for your business. Switch between accounts without signing out.'**
  String get createStoreDescription;

  /// No description provided for @createStore.
  ///
  /// In en, this message translates to:
  /// **'Create a store'**
  String get createStore;

  /// No description provided for @businessStatsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No daily data for this period'**
  String get businessStatsEmpty;

  /// No description provided for @businessStatsError.
  ///
  /// In en, this message translates to:
  /// **'Could not load statistics.'**
  String get businessStatsError;

  /// No description provided for @fillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in the required fields.'**
  String get fillRequiredFields;

  /// No description provided for @applicationLinkUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link.'**
  String get applicationLinkUnavailable;

  /// No description provided for @imageCropError.
  ///
  /// In en, this message translates to:
  /// **'There was an error cropping the image.'**
  String get imageCropError;

  /// No description provided for @stepOfThree.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of 3'**
  String stepOfThree(Object step);

  /// No description provided for @storeLogoDescription.
  ///
  /// In en, this message translates to:
  /// **'Shown on your store page and in the catalog. PNG, 500×500 px'**
  String get storeLogoDescription;

  /// No description provided for @storeBannerDescription.
  ///
  /// In en, this message translates to:
  /// **'Shown on your store page and in the catalog. PNG, 2000×532 px'**
  String get storeBannerDescription;

  /// No description provided for @storeCategoryReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get storeCategoryReady;

  /// No description provided for @storeCategory.
  ///
  /// In en, this message translates to:
  /// **'Store category'**
  String get storeCategory;

  /// No description provided for @businessBenefits.
  ///
  /// In en, this message translates to:
  /// **'Highlight benefits and important details'**
  String get businessBenefits;

  /// No description provided for @storeDescription.
  ///
  /// In en, this message translates to:
  /// **'About the store'**
  String get storeDescription;

  /// No description provided for @businessContact.
  ///
  /// In en, this message translates to:
  /// **'Contact information'**
  String get businessContact;

  /// No description provided for @applicationAccepted.
  ///
  /// In en, this message translates to:
  /// **'Your application has been received'**
  String get applicationAccepted;

  /// No description provided for @applicationAcceptedDescription.
  ///
  /// In en, this message translates to:
  /// **'Our team has received your application.'**
  String get applicationAcceptedDescription;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @pauseListing.
  ///
  /// In en, this message translates to:
  /// **'Deactivate listing'**
  String get pauseListing;

  /// No description provided for @listingIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Listing ID'**
  String get listingIdLabel;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This action will delete your store account and its profile information. Your personal account will not be deleted.'**
  String get deleteAccountWarning;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @englishMenu.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishMenu;

  /// No description provided for @businesses.
  ///
  /// In en, this message translates to:
  /// **'For businesses'**
  String get businesses;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @filterListingsError.
  ///
  /// In en, this message translates to:
  /// **'Could not update favorites: {error}'**
  String filterListingsError(Object error);

  /// No description provided for @favoritesUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update favorites. Please try again.'**
  String get favoritesUpdateFailed;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get genericError;

  /// No description provided for @otpCodePrefix.
  ///
  /// In en, this message translates to:
  /// **'We sent the code to '**
  String get otpCodePrefix;

  /// No description provided for @otpCodeSuffix.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get otpCodeSuffix;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get termsAndConditions;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacy;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchPlaceholder;

  /// No description provided for @storeListings.
  ///
  /// In en, this message translates to:
  /// **'All listings from this user'**
  String get storeListings;

  /// No description provided for @individualSellerLabel.
  ///
  /// In en, this message translates to:
  /// **'Individual seller'**
  String get individualSellerLabel;

  /// No description provided for @blockedSeller.
  ///
  /// In en, this message translates to:
  /// **'This user is blocked. Unblock them to see their listings.'**
  String get blockedSeller;

  /// No description provided for @sellerHours.
  ///
  /// In en, this message translates to:
  /// **'Working hours'**
  String get sellerHours;

  /// No description provided for @storeProfileTab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get storeProfileTab;

  /// No description provided for @listingNoSellerEmail.
  ///
  /// In en, this message translates to:
  /// **'No email address provided'**
  String get listingNoSellerEmail;

  /// No description provided for @listingVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get listingVerified;

  /// No description provided for @listingAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get listingAccount;

  /// No description provided for @listingDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get listingDetails;

  /// No description provided for @askSeller.
  ///
  /// In en, this message translates to:
  /// **'Ask the seller'**
  String get askSeller;

  /// No description provided for @mapSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get mapSearchEmpty;

  /// No description provided for @imageAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get imageAdd;

  /// No description provided for @listingMore.
  ///
  /// In en, this message translates to:
  /// **'More listings'**
  String get listingMore;

  /// No description provided for @listingNoStore.
  ///
  /// In en, this message translates to:
  /// **'No store found'**
  String get listingNoStore;

  /// No description provided for @listingNoUser.
  ///
  /// In en, this message translates to:
  /// **'No user found'**
  String get listingNoUser;

  /// No description provided for @openHours247.
  ///
  /// In en, this message translates to:
  /// **'Open 24/7'**
  String get openHours247;

  /// No description provided for @openHours247Description.
  ///
  /// In en, this message translates to:
  /// **'The store is open all day, every day'**
  String get openHours247Description;

  /// No description provided for @selectWorkDays.
  ///
  /// In en, this message translates to:
  /// **'Select working days'**
  String get selectWorkDays;

  /// No description provided for @listingDetailLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load listing details.'**
  String get listingDetailLoadError;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @loginPhonePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get loginPhonePlaceholder;

  /// No description provided for @registerPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get registerPhone;

  /// No description provided for @listingFormAgreement.
  ///
  /// In en, this message translates to:
  /// **'By posting a listing, you confirm that you will communicate directly with interested buyers.'**
  String get listingFormAgreement;

  /// No description provided for @resetForm.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetForm;

  /// No description provided for @listingEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit listing'**
  String get listingEdit;

  /// No description provided for @listingDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete listing'**
  String get listingDelete;

  /// No description provided for @shareLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get shareLinkCopied;

  /// No description provided for @reportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Your report has been submitted.'**
  String get reportSubmitted;

  /// No description provided for @reportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not submit your report.'**
  String get reportFailed;

  /// No description provided for @subscriptionMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get subscriptionMethod;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay;

  /// No description provided for @subscriptionTerms.
  ///
  /// In en, this message translates to:
  /// **'By tapping “Pay”, you confirm that you accept VidSell\'s User Agreement and Rules.'**
  String get subscriptionTerms;

  /// No description provided for @subscriptionRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} remaining'**
  String subscriptionRemaining(Object count);

  /// No description provided for @subscriptionRenewal.
  ///
  /// In en, this message translates to:
  /// **'The limit resets on the 1st of each month · next: {date}'**
  String subscriptionRenewal(Object date);

  /// No description provided for @serviceDuration.
  ///
  /// In en, this message translates to:
  /// **'Service duration'**
  String get serviceDuration;

  /// No description provided for @amountDue.
  ///
  /// In en, this message translates to:
  /// **'Amount due'**
  String get amountDue;

  /// No description provided for @subscriptionBefore.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get subscriptionBefore;

  /// No description provided for @subscriptionNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get subscriptionNow;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @bonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get bonus;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @businessProfileUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This profile is not available.'**
  String get businessProfileUnavailable;

  /// No description provided for @socialContact.
  ///
  /// In en, this message translates to:
  /// **'Social media'**
  String get socialContact;

  /// No description provided for @banner.
  ///
  /// In en, this message translates to:
  /// **'Banner'**
  String get banner;

  /// No description provided for @storeLogo.
  ///
  /// In en, this message translates to:
  /// **'Store logo'**
  String get storeLogo;

  /// No description provided for @storeBanner.
  ///
  /// In en, this message translates to:
  /// **'Store banner'**
  String get storeBanner;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @registerDetailsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter your information to post listings and start buying and selling.'**
  String get registerDetailsPrompt;

  /// No description provided for @applicationReviewMessage.
  ///
  /// In en, this message translates to:
  /// **'Our team has received your application. We will contact you after the review.'**
  String get applicationReviewMessage;

  /// No description provided for @callUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not place the call.'**
  String get callUnavailable;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Do you want to log out?'**
  String get logoutConfirmation;

  /// No description provided for @logoutDescription.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again after logging out.'**
  String get logoutDescription;

  /// No description provided for @discardDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard the entered information?'**
  String get discardDataTitle;

  /// No description provided for @discardDataDescription.
  ///
  /// In en, this message translates to:
  /// **'If you go back, the information you entered will be deleted.'**
  String get discardDataDescription;

  /// No description provided for @stayOnForm.
  ///
  /// In en, this message translates to:
  /// **'Stay on the form'**
  String get stayOnForm;

  /// No description provided for @businessListingsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Add a product or service you want to sell.'**
  String get businessListingsPrompt;

  /// No description provided for @profileEmailMissing.
  ///
  /// In en, this message translates to:
  /// **'No email address provided'**
  String get profileEmailMissing;

  /// No description provided for @storeDeleteDescription.
  ///
  /// In en, this message translates to:
  /// **'This action will delete your store account and its profile information. Your personal account will remain.'**
  String get storeDeleteDescription;

  /// No description provided for @noDailyStats.
  ///
  /// In en, this message translates to:
  /// **'There is no daily data for this period.'**
  String get noDailyStats;

  /// No description provided for @retryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retryAgain;

  /// No description provided for @accountAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get accountAbout;

  /// No description provided for @sellerOtherListings.
  ///
  /// In en, this message translates to:
  /// **'All listings from this user'**
  String get sellerOtherListings;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @videoLimit.
  ///
  /// In en, this message translates to:
  /// **'You can add only one video.'**
  String get videoLimit;

  /// No description provided for @videoAddFailure.
  ///
  /// In en, this message translates to:
  /// **'Could not add the video.'**
  String get videoAddFailure;

  /// No description provided for @open247.
  ///
  /// In en, this message translates to:
  /// **'Open 24/7'**
  String get open247;

  /// No description provided for @open247Description.
  ///
  /// In en, this message translates to:
  /// **'The store is open all day, every day.'**
  String get open247Description;

  /// No description provided for @workDays.
  ///
  /// In en, this message translates to:
  /// **'Working days'**
  String get workDays;

  /// No description provided for @workDaysAndHours.
  ///
  /// In en, this message translates to:
  /// **'Working days and hours'**
  String get workDaysAndHours;

  /// No description provided for @stepOneOfThree.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 3'**
  String get stepOneOfThree;

  /// No description provided for @stepTwoOfThree.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 3'**
  String get stepTwoOfThree;

  /// No description provided for @storeLogoInfo.
  ///
  /// In en, this message translates to:
  /// **'Shown on your store page and in the catalog. PNG, 500×500 px.'**
  String get storeLogoInfo;

  /// No description provided for @storeBannerInfo.
  ///
  /// In en, this message translates to:
  /// **'Shown on your store page and in the catalog. PNG, 2000×532 px.'**
  String get storeBannerInfo;

  /// No description provided for @businessLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to the cabinet'**
  String get businessLoginTitle;

  /// No description provided for @subscriptionAccepted.
  ///
  /// In en, this message translates to:
  /// **'By tapping “Pay”, you confirm that you accept VidSell\'s User Agreement and Rules.'**
  String get subscriptionAccepted;

  /// No description provided for @remainingListingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} remaining'**
  String remainingListingCount(Object count);

  /// No description provided for @remainingListingMessage.
  ///
  /// In en, this message translates to:
  /// **'After this listing, you will have {count} free listing remaining.'**
  String remainingListingMessage(Object count);

  /// No description provided for @genericRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get genericRetry;

  /// No description provided for @newListings.
  ///
  /// In en, this message translates to:
  /// **'New listings'**
  String get newListings;

  /// No description provided for @subscriptionPremium.
  ///
  /// In en, this message translates to:
  /// **'Activate Premium'**
  String get subscriptionPremium;

  /// No description provided for @subscriptionVip.
  ///
  /// In en, this message translates to:
  /// **'Activate VIP'**
  String get subscriptionVip;

  /// No description provided for @sellerAsk.
  ///
  /// In en, this message translates to:
  /// **'Ask the seller'**
  String get sellerAsk;

  /// No description provided for @termsAgreementLead.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to the'**
  String get termsAgreementLead;

  /// No description provided for @termsAgreementEnd.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get termsAgreementEnd;

  /// No description provided for @distanceSalesAgreement.
  ///
  /// In en, this message translates to:
  /// **'Distance sales agreement'**
  String get distanceSalesAgreement;

  /// No description provided for @personalLink.
  ///
  /// In en, this message translates to:
  /// **'Personal link'**
  String get personalLink;

  /// No description provided for @newListingVideoTitle.
  ///
  /// In en, this message translates to:
  /// **'New listing > Add a video'**
  String get newListingVideoTitle;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get inStock;

  /// No description provided for @profileSummary.
  ///
  /// In en, this message translates to:
  /// **'Profile photo, name, description'**
  String get profileSummary;

  /// No description provided for @catalog.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get catalog;

  /// No description provided for @contactDetails.
  ///
  /// In en, this message translates to:
  /// **'Address, contact details'**
  String get contactDetails;

  /// No description provided for @generalInfo.
  ///
  /// In en, this message translates to:
  /// **'General information'**
  String get generalInfo;

  /// No description provided for @noStore.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have a store'**
  String get noStore;

  /// No description provided for @createStorePrompt.
  ///
  /// In en, this message translates to:
  /// **'Create a dedicated store page for your business. Switch between accounts without signing out.'**
  String get createStorePrompt;

  /// No description provided for @accountIdLabel.
  ///
  /// In en, this message translates to:
  /// **'ID: {id}'**
  String accountIdLabel(Object id);

  /// No description provided for @zeroBalance.
  ///
  /// In en, this message translates to:
  /// **'0'**
  String get zeroBalance;

  /// No description provided for @efficiency.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get efficiency;

  /// No description provided for @clearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear filter'**
  String get clearFilter;

  /// No description provided for @sellProductPrompt.
  ///
  /// In en, this message translates to:
  /// **'Add a product or service you want to sell.'**
  String get sellProductPrompt;

  /// No description provided for @userProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get userProfile;

  /// No description provided for @storeOpensAt.
  ///
  /// In en, this message translates to:
  /// **'Opens at {time}'**
  String storeOpensAt(Object time);

  /// No description provided for @askAboutProduct.
  ///
  /// In en, this message translates to:
  /// **'Ask the seller about this product'**
  String get askAboutProduct;

  /// No description provided for @listingsTab.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get listingsTab;

  /// No description provided for @applicationIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Application ID: {id}'**
  String applicationIdLabel(Object id);

  /// No description provided for @videoFrameGenerationError.
  ///
  /// In en, this message translates to:
  /// **'Could not generate a video frame: {error}'**
  String videoFrameGenerationError(Object error);

  /// No description provided for @videoFrameCreationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create a video frame. Please try again.'**
  String get videoFrameCreationFailed;

  /// No description provided for @listingRulesText.
  ///
  /// In en, this message translates to:
  /// **'By posting a listing, you confirm that you will communicate directly with interested buyers.'**
  String get listingRulesText;

  /// No description provided for @storeLogoHelp.
  ///
  /// In en, this message translates to:
  /// **'Shown on your store page and in the catalog. PNG, 500×500 px.'**
  String get storeLogoHelp;

  /// No description provided for @storeBannerHelp.
  ///
  /// In en, this message translates to:
  /// **'Shown on your store page and in the catalog. PNG, 2000×532 px.'**
  String get storeBannerHelp;

  /// No description provided for @openUntil.
  ///
  /// In en, this message translates to:
  /// **'Open until {time}'**
  String openUntil(Object time);

  /// No description provided for @generalSchedule.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalSchedule;

  /// No description provided for @individualSchedule.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get individualSchedule;

  /// No description provided for @scheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Work schedule'**
  String get scheduleTitle;

  /// No description provided for @scheduleSummary.
  ///
  /// In en, this message translates to:
  /// **'Your schedule'**
  String get scheduleSummary;

  /// No description provided for @noWorkingDaysSelected.
  ///
  /// In en, this message translates to:
  /// **'No working days selected'**
  String get noWorkingDaysSelected;

  /// No description provided for @weekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekdaySunday;

  /// No description provided for @bankCard.
  ///
  /// In en, this message translates to:
  /// **'Bank card'**
  String get bankCard;

  /// No description provided for @terminalPayment.
  ///
  /// In en, this message translates to:
  /// **'Terminal payment'**
  String get terminalPayment;

  /// No description provided for @personalAccountPayment.
  ///
  /// In en, this message translates to:
  /// **'Personal account ({balance})'**
  String personalAccountPayment(Object balance);

  /// No description provided for @activateFree.
  ///
  /// In en, this message translates to:
  /// **'Activate for free'**
  String get activateFree;

  /// No description provided for @activateNow.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activateNow;

  /// No description provided for @threeDays.
  ///
  /// In en, this message translates to:
  /// **'3 days'**
  String get threeDays;

  /// No description provided for @showCategoryListings.
  ///
  /// In en, this message translates to:
  /// **'Show listings in {category}'**
  String showCategoryListings(Object category);

  /// No description provided for @quotaRemaining.
  ///
  /// In en, this message translates to:
  /// **'{remaining} / {total} remaining'**
  String quotaRemaining(Object remaining, Object total);

  /// No description provided for @freeListingsAfter.
  ///
  /// In en, this message translates to:
  /// **'After this listing, you will have {count} free listing remaining.'**
  String freeListingsAfter(Object count);

  /// No description provided for @submitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// No description provided for @listingStockLocation.
  ///
  /// In en, this message translates to:
  /// **'In stock · {location}'**
  String listingStockLocation(Object location);

  /// No description provided for @listingSuccessDescription.
  ///
  /// In en, this message translates to:
  /// **'Your listing will be published after it has been reviewed. The selected service will activate once the listing is approved. If the listing is rejected, the payment will be refunded.'**
  String get listingSuccessDescription;

  /// No description provided for @listingPromotionVipDescription.
  ///
  /// In en, this message translates to:
  /// **'Featured on the home page and shown with a larger map marker'**
  String get listingPromotionVipDescription;

  /// No description provided for @listingPromotionPremiumDescription.
  ///
  /// In en, this message translates to:
  /// **'A listing with a frame and badge'**
  String get listingPromotionPremiumDescription;

  /// No description provided for @listingPromotionBoostDescription.
  ///
  /// In en, this message translates to:
  /// **'Moves your listing higher in the list'**
  String get listingPromotionBoostDescription;

  /// No description provided for @listingBoostButton.
  ///
  /// In en, this message translates to:
  /// **'Boost'**
  String get listingBoostButton;

  /// No description provided for @vipSubscriptionDescription.
  ///
  /// In en, this message translates to:
  /// **'Your listing will be promoted in search results, shown randomly among VIP listings in its category, and highlighted with a larger map marker.'**
  String get vipSubscriptionDescription;

  /// No description provided for @premiumSubscriptionDescription.
  ///
  /// In en, this message translates to:
  /// **'Your listing will be promoted in search results, shown randomly among VIP listings in its category, and remain on the home page until the service expires.'**
  String get premiumSubscriptionDescription;

  /// No description provided for @boostSubscriptionDescription.
  ///
  /// In en, this message translates to:
  /// **'Your listing will move to the top of all search results.'**
  String get boostSubscriptionDescription;

  /// No description provided for @vipFreeLimit.
  ///
  /// In en, this message translates to:
  /// **'VIP free limit · this month'**
  String get vipFreeLimit;

  /// No description provided for @premiumFreeLimit.
  ///
  /// In en, this message translates to:
  /// **'Premium free limit · this month'**
  String get premiumFreeLimit;

  /// No description provided for @boostFreeLimit.
  ///
  /// In en, this message translates to:
  /// **'Boost free limit · this month'**
  String get boostFreeLimit;

  /// No description provided for @planDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String planDays(int count);

  /// No description provided for @planTimes.
  ///
  /// In en, this message translates to:
  /// **'{count} times'**
  String planTimes(int count);

  /// No description provided for @everyHours.
  ///
  /// In en, this message translates to:
  /// **'every {count} hours'**
  String everyHours(int count);

  /// No description provided for @boostDailyBenefit.
  ///
  /// In en, this message translates to:
  /// **'BOOST EVERY DAY'**
  String get boostDailyBenefit;

  /// No description provided for @makeVip.
  ///
  /// In en, this message translates to:
  /// **'MAKE VIP'**
  String get makeVip;

  /// No description provided for @boostServiceFree.
  ///
  /// In en, this message translates to:
  /// **'Boost · {count} time (free)'**
  String boostServiceFree(int count);

  /// No description provided for @vipServiceFree.
  ///
  /// In en, this message translates to:
  /// **'VIP · {duration} (free)'**
  String vipServiceFree(String duration);

  /// No description provided for @premiumServiceFree.
  ///
  /// In en, this message translates to:
  /// **'Premium · {duration} (free)'**
  String premiumServiceFree(String duration);

  /// No description provided for @listingCondition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get listingCondition;

  /// No description provided for @listingDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get listingDelivery;

  /// No description provided for @freeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Free delivery'**
  String get freeDelivery;

  /// No description provided for @deliveryToRegions.
  ///
  /// In en, this message translates to:
  /// **'Delivery to regions'**
  String get deliveryToRegions;

  /// No description provided for @pickupAtAddress.
  ///
  /// In en, this message translates to:
  /// **'Pickup from address'**
  String get pickupAtAddress;

  /// No description provided for @listingContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get listingContent;

  /// No description provided for @listingDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Add the benefits and important details'**
  String get listingDescriptionHint;

  /// No description provided for @listingContactMethod.
  ///
  /// In en, this message translates to:
  /// **'Contact method'**
  String get listingContactMethod;

  /// No description provided for @callsAndMessages.
  ///
  /// In en, this message translates to:
  /// **'Calls and messages'**
  String get callsAndMessages;

  /// No description provided for @callsOnly.
  ///
  /// In en, this message translates to:
  /// **'Calls only'**
  String get callsOnly;

  /// No description provided for @messagesOnlyHiddenNumber.
  ///
  /// In en, this message translates to:
  /// **'Messages only (your number will be hidden)'**
  String get messagesOnlyHiddenNumber;

  /// No description provided for @usedCondition.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get usedCondition;

  /// No description provided for @fillListingFields.
  ///
  /// In en, this message translates to:
  /// **'Please complete these fields: {fields}.'**
  String fillListingFields(String fields);

  /// No description provided for @listingFieldPrice.
  ///
  /// In en, this message translates to:
  /// **'price'**
  String get listingFieldPrice;

  /// No description provided for @listingFieldCity.
  ///
  /// In en, this message translates to:
  /// **'city'**
  String get listingFieldCity;

  /// No description provided for @listingCityNotFound.
  ///
  /// In en, this message translates to:
  /// **'Choose a city from the available city list.'**
  String get listingCityNotFound;

  /// No description provided for @listingFieldCondition.
  ///
  /// In en, this message translates to:
  /// **'condition'**
  String get listingFieldCondition;

  /// No description provided for @listingFieldModel.
  ///
  /// In en, this message translates to:
  /// **'model'**
  String get listingFieldModel;

  /// No description provided for @listingFieldDelivery.
  ///
  /// In en, this message translates to:
  /// **'delivery option'**
  String get listingFieldDelivery;

  /// No description provided for @listingFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'title'**
  String get listingFieldTitle;

  /// No description provided for @listingFieldName.
  ///
  /// In en, this message translates to:
  /// **'name'**
  String get listingFieldName;

  /// No description provided for @listingFieldEmail.
  ///
  /// In en, this message translates to:
  /// **'email'**
  String get listingFieldEmail;

  /// No description provided for @listingFieldPhone.
  ///
  /// In en, this message translates to:
  /// **'phone number'**
  String get listingFieldPhone;

  /// No description provided for @listingFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'description'**
  String get listingFieldDescription;

  /// No description provided for @listingFieldMedia.
  ///
  /// In en, this message translates to:
  /// **'at least one photo or video'**
  String get listingFieldMedia;

  /// No description provided for @listingMediaRequired.
  ///
  /// In en, this message translates to:
  /// **'Add at least one photo or video to your listing.'**
  String get listingMediaRequired;

  /// No description provided for @listingService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get listingService;

  /// No description provided for @amountToPay.
  ///
  /// In en, this message translates to:
  /// **'Amount due'**
  String get amountToPay;

  /// No description provided for @listingHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get listingHome;

  /// No description provided for @listingSummary.
  ///
  /// In en, this message translates to:
  /// **'Listing'**
  String get listingSummary;

  /// No description provided for @listingPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get listingPriceLabel;

  /// No description provided for @newCondition.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newCondition;

  /// No description provided for @moderationStatus.
  ///
  /// In en, this message translates to:
  /// **'UNDER REVIEW'**
  String get moderationStatus;

  /// No description provided for @zeroAmountAzn.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get zeroAmountAzn;

  /// No description provided for @activateVip.
  ///
  /// In en, this message translates to:
  /// **'Activate VIP'**
  String get activateVip;

  /// No description provided for @activatePremium.
  ///
  /// In en, this message translates to:
  /// **'Activate Premium'**
  String get activatePremium;

  /// No description provided for @standardService.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standardService;

  /// No description provided for @listingStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get listingStatusLabel;

  /// No description provided for @aboutWhatTitle.
  ///
  /// In en, this message translates to:
  /// **'What is Vidsell?'**
  String get aboutWhatTitle;

  /// No description provided for @aboutWhatBody.
  ///
  /// In en, this message translates to:
  /// **'Vidsell is a marketplace platform that lets users create listings, search for products, and contact sellers.'**
  String get aboutWhatBody;

  /// No description provided for @aboutFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Key features'**
  String get aboutFeaturesTitle;

  /// No description provided for @aboutFeaturesBody.
  ///
  /// In en, this message translates to:
  /// **'Discover listings by category, search and filter, save listings, and message sellers.'**
  String get aboutFeaturesBody;

  /// No description provided for @aboutVersionTitle.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersionTitle;

  /// No description provided for @aboutVersionBody.
  ///
  /// In en, this message translates to:
  /// **'This version of the app uses mock data sources in preparation for backend integration. Data storage and account synchronization will be enabled when the backend is connected.'**
  String get aboutVersionBody;

  /// No description provided for @privacyDataCollectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Data we collect'**
  String get privacyDataCollectedTitle;

  /// No description provided for @privacyDataCollectedBody.
  ///
  /// In en, this message translates to:
  /// **'An account uses your phone number, name, and, when required, email address. Listing, message, saved-item, and followed-store data may be associated with your account.'**
  String get privacyDataCollectedBody;

  /// No description provided for @privacyDataUseTitle.
  ///
  /// In en, this message translates to:
  /// **'How we use your data'**
  String get privacyDataUseTitle;

  /// No description provided for @privacyDataUseBody.
  ///
  /// In en, this message translates to:
  /// **'Data is used to manage your account, display listings, provide messaging, maintain security, and deliver support services.'**
  String get privacyDataUseBody;

  /// No description provided for @privacyRetentionTitle.
  ///
  /// In en, this message translates to:
  /// **'Data retention and security'**
  String get privacyRetentionTitle;

  /// No description provided for @privacyRetentionBody.
  ///
  /// In en, this message translates to:
  /// **'Access to data should be limited according to account permissions. During real backend integration, retention periods, deletion requests, and security measures will be defined in the backend policy.'**
  String get privacyRetentionBody;

  /// No description provided for @privacyRightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your rights'**
  String get privacyRightsTitle;

  /// No description provided for @privacyRightsBody.
  ///
  /// In en, this message translates to:
  /// **'You can update your profile and contact support with questions about deleting account data or handling personal information.'**
  String get privacyRightsBody;

  /// No description provided for @agreementUseTitle.
  ///
  /// In en, this message translates to:
  /// **'Use of the service'**
  String get agreementUseTitle;

  /// No description provided for @agreementUseBody.
  ///
  /// In en, this message translates to:
  /// **'Only lawful and truthful listings that do not violate others\' rights may be posted on Vidsell. You are responsible for keeping your account information confidential.'**
  String get agreementUseBody;

  /// No description provided for @agreementListingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Listings and transactions'**
  String get agreementListingsTitle;

  /// No description provided for @agreementListingsBody.
  ///
  /// In en, this message translates to:
  /// **'The seller is responsible for a listing\'s content, price, photos, and contact details. Vidsell may moderate listings and restrict content that does not follow the rules.'**
  String get agreementListingsBody;

  /// No description provided for @agreementMessagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messaging'**
  String get agreementMessagesTitle;

  /// No description provided for @agreementMessagesBody.
  ///
  /// In en, this message translates to:
  /// **'Abuse, spam, fraud, and misuse of personal information are prohibited in messages. Report suspicious activity to support.'**
  String get agreementMessagesBody;

  /// No description provided for @agreementRestrictionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Account restrictions'**
  String get agreementRestrictionsTitle;

  /// No description provided for @agreementRestrictionsBody.
  ///
  /// In en, this message translates to:
  /// **'Accounts and listings may be restricted temporarily or permanently if the rules are violated. You can contact support about a decision.'**
  String get agreementRestrictionsBody;

  /// No description provided for @offerPartiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Parties to the agreement'**
  String get offerPartiesTitle;

  /// No description provided for @offerPartiesBody.
  ///
  /// In en, this message translates to:
  /// **'This offer sets out the terms for using Vidsell services and the main conditions between the user and the platform.'**
  String get offerPartiesBody;

  /// No description provided for @offerPlatformRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'The platform\'s role'**
  String get offerPlatformRoleTitle;

  /// No description provided for @offerPlatformRoleBody.
  ///
  /// In en, this message translates to:
  /// **'Vidsell provides listing, search, contact, and account services. The buyer and seller are responsible for their product and payment arrangements.'**
  String get offerPlatformRoleBody;

  /// No description provided for @offerPaidServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Paid services'**
  String get offerPaidServicesTitle;

  /// No description provided for @offerPaidServicesBody.
  ///
  /// In en, this message translates to:
  /// **'Paid services are provided at the prices and under the terms shown in the app. Payment confirmation and refunds will follow the rules of the production payment provider and backend.'**
  String get offerPaidServicesBody;

  /// No description provided for @offerChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Changes'**
  String get offerChangesTitle;

  /// No description provided for @offerChangesBody.
  ///
  /// In en, this message translates to:
  /// **'These terms may be updated when the service or laws change. Updated terms take effect when published in the app.'**
  String get offerChangesBody;

  /// No description provided for @rulesProhibitedTitle.
  ///
  /// In en, this message translates to:
  /// **'Prohibited listings'**
  String get rulesProhibitedTitle;

  /// No description provided for @rulesProhibitedBody.
  ///
  /// In en, this message translates to:
  /// **'Listings for illegal products, counterfeit goods, weapons, drugs, stolen items, and products dangerous to human health are prohibited.'**
  String get rulesProhibitedBody;

  /// No description provided for @rulesQualityTitle.
  ///
  /// In en, this message translates to:
  /// **'Listing quality'**
  String get rulesQualityTitle;

  /// No description provided for @rulesQualityBody.
  ///
  /// In en, this message translates to:
  /// **'The title, description, price, and photos must accurately represent the product. Duplicate listings, misleading prices, and spam are not accepted.'**
  String get rulesQualityBody;

  /// No description provided for @rulesCommunicationTitle.
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get rulesCommunicationTitle;

  /// No description provided for @rulesCommunicationBody.
  ///
  /// In en, this message translates to:
  /// **'Treat other users respectfully. Report abuse, threats, spam, attempted fraud, or requests for risky off-platform payments.'**
  String get rulesCommunicationBody;

  /// No description provided for @rulesComplaintsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reporting'**
  String get rulesComplaintsTitle;

  /// No description provided for @rulesComplaintsBody.
  ///
  /// In en, this message translates to:
  /// **'Use the listing or user report feature when you see a rule violation. In urgent safety situations, contact local law enforcement.'**
  String get rulesComplaintsBody;

  /// No description provided for @supportPopularQuestions.
  ///
  /// In en, this message translates to:
  /// **'Popular questions'**
  String get supportPopularQuestions;

  /// No description provided for @supportListing.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get supportListing;

  /// No description provided for @supportPersonalCabinet.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get supportPersonalCabinet;

  /// No description provided for @supportPostingListing.
  ///
  /// In en, this message translates to:
  /// **'Posting a listing'**
  String get supportPostingListing;

  /// No description provided for @faqCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'How do I create an account?'**
  String get faqCreateAccount;

  /// No description provided for @faqEditListing.
  ///
  /// In en, this message translates to:
  /// **'How do I edit a listing?'**
  String get faqEditListing;

  /// No description provided for @faqFindMessages.
  ///
  /// In en, this message translates to:
  /// **'Where can I find my messages?'**
  String get faqFindMessages;

  /// No description provided for @faqReportListing.
  ///
  /// In en, this message translates to:
  /// **'How do I report a listing?'**
  String get faqReportListing;

  /// No description provided for @faqPostListing.
  ///
  /// In en, this message translates to:
  /// **'How do I post a listing?'**
  String get faqPostListing;

  /// No description provided for @faqPublishTime.
  ///
  /// In en, this message translates to:
  /// **'When will my listing be published?'**
  String get faqPublishTime;

  /// No description provided for @faqDeleteListing.
  ///
  /// In en, this message translates to:
  /// **'How do I delete a listing?'**
  String get faqDeleteListing;

  /// No description provided for @faqListingRejected.
  ///
  /// In en, this message translates to:
  /// **'Why was my listing rejected?'**
  String get faqListingRejected;

  /// No description provided for @faqEditProfile.
  ///
  /// In en, this message translates to:
  /// **'How do I change my profile information?'**
  String get faqEditProfile;

  /// No description provided for @faqVerifyPhone.
  ///
  /// In en, this message translates to:
  /// **'How is my phone number verified?'**
  String get faqVerifyPhone;

  /// No description provided for @faqForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'I forgot my password'**
  String get faqForgotPassword;

  /// No description provided for @faqDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'How do I delete my account?'**
  String get faqDeleteAccount;

  /// No description provided for @faqAddMedia.
  ///
  /// In en, this message translates to:
  /// **'How do I add photos and videos?'**
  String get faqAddMedia;

  /// No description provided for @faqSetPrice.
  ///
  /// In en, this message translates to:
  /// **'How should I set the price?'**
  String get faqSetPrice;

  /// No description provided for @faqChooseCategory.
  ///
  /// In en, this message translates to:
  /// **'How do I choose a category?'**
  String get faqChooseCategory;

  /// No description provided for @faqModeration.
  ///
  /// In en, this message translates to:
  /// **'What is listing moderation?'**
  String get faqModeration;

  /// No description provided for @faqAccountAnswer.
  ///
  /// In en, this message translates to:
  /// **'Manage your account information from your profile. Phone verification is required to keep your account secure.'**
  String get faqAccountAnswer;

  /// No description provided for @faqListingAnswer.
  ///
  /// In en, this message translates to:
  /// **'Complete the listing form, add media, and submit it. Your listing will be activated after review.'**
  String get faqListingAnswer;

  /// No description provided for @faqProfileAnswer.
  ///
  /// In en, this message translates to:
  /// **'You can update your details, change your password, and send account-related requests from your profile and account pages.'**
  String get faqProfileAnswer;

  /// No description provided for @faqQualityAnswer.
  ///
  /// In en, this message translates to:
  /// **'Add an accurate title, description, price, and clear media. Listings that follow the rules are published after moderation.'**
  String get faqQualityAnswer;

  /// No description provided for @homeForYou.
  ///
  /// In en, this message translates to:
  /// **'For you'**
  String get homeForYou;

  /// No description provided for @followingTab.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followingTab;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @followingStatus.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followingStatus;

  /// No description provided for @followerCount.
  ///
  /// In en, this message translates to:
  /// **'{count} followers'**
  String followerCount(int count);

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Product details'**
  String get productDetails;

  /// No description provided for @productCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get productCity;

  /// No description provided for @productColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get productColor;

  /// No description provided for @productCondition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get productCondition;

  /// No description provided for @productDescriptionMissing.
  ///
  /// In en, this message translates to:
  /// **'No description provided.'**
  String get productDescriptionMissing;

  /// No description provided for @productPhoneReveal.
  ///
  /// In en, this message translates to:
  /// **'Show number'**
  String get productPhoneReveal;

  /// No description provided for @listingNumber.
  ///
  /// In en, this message translates to:
  /// **'Listing number'**
  String get listingNumber;

  /// No description provided for @listingUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get listingUpdated;

  /// No description provided for @sampleProductDescription.
  ///
  /// In en, this message translates to:
  /// **'📱 Modern technology and premium design at a great price!\n\n🔒 Includes a one-year official international warranty.\n\n🔹 Official sale with quality guaranteed.'**
  String get sampleProductDescription;

  /// No description provided for @sellerGreetingCurrent.
  ///
  /// In en, this message translates to:
  /// **'Hello, is this still available?'**
  String get sellerGreetingCurrent;

  /// No description provided for @sellerGreetingInterest.
  ///
  /// In en, this message translates to:
  /// **'Hello, I\'m interested!'**
  String get sellerGreetingInterest;

  /// No description provided for @sellerNumberCopied.
  ///
  /// In en, this message translates to:
  /// **'Number copied: {number}'**
  String sellerNumberCopied(String number);

  /// No description provided for @followingListTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get followingListTitle;

  /// No description provided for @savedListingsEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Browse listings, tap the save icon, and they will appear here.'**
  String get savedListingsEmptyDescription;

  /// No description provided for @followedStoresEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Follow stores to keep up with their new listings.'**
  String get followedStoresEmptyDescription;

  /// No description provided for @searchSuggestionsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load suggestions.'**
  String get searchSuggestionsLoadError;

  /// No description provided for @searchResultsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load search results.'**
  String get searchResultsLoadError;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get searchNoResults;

  /// No description provided for @searchNoSuggestions.
  ///
  /// In en, this message translates to:
  /// **'No suggestions found.'**
  String get searchNoSuggestions;

  /// No description provided for @reportProhibitedItem.
  ///
  /// In en, this message translates to:
  /// **'Prohibited item or service'**
  String get reportProhibitedItem;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @sellerCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get sellerCall;

  /// No description provided for @sellerMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get sellerMessage;

  /// No description provided for @chatSelectedDeleteCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 message will be deleted.} other{{count} messages will be deleted.}}'**
  String chatSelectedDeleteCount(int count);

  /// No description provided for @chatNoTextToCopy.
  ///
  /// In en, this message translates to:
  /// **'There is no message text to copy.'**
  String get chatNoTextToCopy;

  /// No description provided for @chatSelectOneToReply.
  ///
  /// In en, this message translates to:
  /// **'Select only one message to reply to.'**
  String get chatSelectOneToReply;

  /// No description provided for @chatReplyDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'You can\'t reply to a deleted message.'**
  String get chatReplyDeletedMessage;

  /// No description provided for @chatImagePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'[Image]'**
  String get chatImagePlaceholder;

  /// No description provided for @chatCleared.
  ///
  /// In en, this message translates to:
  /// **'Conversation cleared'**
  String get chatCleared;

  /// No description provided for @unblockUser.
  ///
  /// In en, this message translates to:
  /// **'Unblock user'**
  String get unblockUser;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get blockUser;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications'**
  String get enableNotifications;

  /// No description provided for @disableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Turn off notifications'**
  String get disableNotifications;

  /// No description provided for @userBlocked.
  ///
  /// In en, this message translates to:
  /// **'User blocked'**
  String get userBlocked;

  /// No description provided for @userUnblocked.
  ///
  /// In en, this message translates to:
  /// **'User unblocked'**
  String get userUnblocked;

  /// No description provided for @userReportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Your report has been sent.'**
  String get userReportSubmitted;

  /// No description provided for @notificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications turned off'**
  String get notificationsDisabled;

  /// No description provided for @notificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications turned on'**
  String get notificationsEnabled;

  /// No description provided for @chatMessageSeller.
  ///
  /// In en, this message translates to:
  /// **'Message the seller'**
  String get chatMessageSeller;

  /// No description provided for @chatMessageSellerAboutListing.
  ///
  /// In en, this message translates to:
  /// **'Message the seller about this listing'**
  String get chatMessageSellerAboutListing;

  /// No description provided for @sortByDate.
  ///
  /// In en, this message translates to:
  /// **'By date'**
  String get sortByDate;

  /// No description provided for @sortByUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread first'**
  String get sortByUnread;

  /// No description provided for @chatSortRecent.
  ///
  /// In en, this message translates to:
  /// **'Most recent'**
  String get chatSortRecent;

  /// No description provided for @mockBabyStroller.
  ///
  /// In en, this message translates to:
  /// **'Chicco baby stroller'**
  String get mockBabyStroller;

  /// No description provided for @mockStoreDescriptionHome.
  ///
  /// In en, this message translates to:
  /// **'A quality selection of home and household products.'**
  String get mockStoreDescriptionHome;

  /// No description provided for @mockStoreDescriptionTech.
  ///
  /// In en, this message translates to:
  /// **'Phones, laptops, computers, and electronics.'**
  String get mockStoreDescriptionTech;

  /// No description provided for @mockStoreDescriptionFashion.
  ///
  /// In en, this message translates to:
  /// **'Clothing for women, men, and children.'**
  String get mockStoreDescriptionFashion;

  /// No description provided for @mockStoreDescriptionAuto.
  ///
  /// In en, this message translates to:
  /// **'Car parts, oils, and accessories.'**
  String get mockStoreDescriptionAuto;

  /// No description provided for @mockStoreDescriptionGarden.
  ///
  /// In en, this message translates to:
  /// **'Flowers, decorative plants, and gardening supplies.'**
  String get mockStoreDescriptionGarden;

  /// No description provided for @mockStoreDescriptionTools.
  ///
  /// In en, this message translates to:
  /// **'Tools for professionals and home users.'**
  String get mockStoreDescriptionTools;

  /// No description provided for @mockStoreDescriptionBaby.
  ///
  /// In en, this message translates to:
  /// **'Baby clothes, toys, and strollers.'**
  String get mockStoreDescriptionBaby;

  /// No description provided for @mockStoreDescriptionBooks.
  ///
  /// In en, this message translates to:
  /// **'Fiction, non-fiction, and school supplies.'**
  String get mockStoreDescriptionBooks;

  /// No description provided for @istanbulDistrictAddress.
  ///
  /// In en, this message translates to:
  /// **'Kadıköy, Istanbul'**
  String get istanbulDistrictAddress;

  /// No description provided for @storeShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get storeShowLess;

  /// No description provided for @storeShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get storeShowMore;

  /// No description provided for @savedSearchesEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Save searches to keep up with new listings.'**
  String get savedSearchesEmptyDescription;

  /// No description provided for @productCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get productCategory;

  /// No description provided for @productSubcategory.
  ///
  /// In en, this message translates to:
  /// **'Subcategory'**
  String get productSubcategory;

  /// No description provided for @productBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get productBrand;

  /// No description provided for @productModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get productModel;

  /// No description provided for @productMemory.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get productMemory;

  /// No description provided for @productSimCard.
  ///
  /// In en, this message translates to:
  /// **'SIM card'**
  String get productSimCard;

  /// No description provided for @productDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get productDelivery;

  /// No description provided for @listingViewCount.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get listingViewCount;

  /// No description provided for @todayAt.
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String todayAt(String time);

  /// No description provided for @reportSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get reportSpam;

  /// No description provided for @reportListingNotCurrent.
  ///
  /// In en, this message translates to:
  /// **'Listing is no longer available'**
  String get reportListingNotCurrent;

  /// No description provided for @reportDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate listing'**
  String get reportDuplicate;

  /// No description provided for @reportWrongCategory.
  ///
  /// In en, this message translates to:
  /// **'Wrong category'**
  String get reportWrongCategory;

  /// No description provided for @reportFraud.
  ///
  /// In en, this message translates to:
  /// **'Fraud'**
  String get reportFraud;

  /// No description provided for @chooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get chooseCategory;

  /// No description provided for @startSearching.
  ///
  /// In en, this message translates to:
  /// **'Start searching'**
  String get startSearching;

  /// No description provided for @allStores.
  ///
  /// In en, this message translates to:
  /// **'All stores'**
  String get allStores;

  /// No description provided for @messageFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get messageFilterAll;

  /// No description provided for @messageFilterSales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get messageFilterSales;

  /// No description provided for @messageFilterPurchases.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get messageFilterPurchases;

  /// No description provided for @messageFilterBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get messageFilterBlocked;

  /// No description provided for @messageSortByDate.
  ///
  /// In en, this message translates to:
  /// **'By date'**
  String get messageSortByDate;

  /// No description provided for @messageSortUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread first'**
  String get messageSortUnread;

  /// No description provided for @mockWomenShoes.
  ///
  /// In en, this message translates to:
  /// **'Women\'s Nike sneakers'**
  String get mockWomenShoes;

  /// No description provided for @mockBabyStrollerListing.
  ///
  /// In en, this message translates to:
  /// **'Chicco baby stroller'**
  String get mockBabyStrollerListing;

  /// No description provided for @mockIphoneListingTitle.
  ///
  /// In en, this message translates to:
  /// **'Apple iPhone 17 Pro 256GB Cosmic Orange'**
  String get mockIphoneListingTitle;

  /// No description provided for @chatCopiedMessageCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 message copied} other{{count} messages copied}}'**
  String chatCopiedMessageCount(int count);

  /// No description provided for @cityBaku.
  ///
  /// In en, this message translates to:
  /// **'Baku'**
  String get cityBaku;

  /// No description provided for @categoryElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get categoryElectronics;

  /// No description provided for @categoryPhones.
  ///
  /// In en, this message translates to:
  /// **'Phones'**
  String get categoryPhones;

  /// No description provided for @allCategoryItems.
  ///
  /// In en, this message translates to:
  /// **'All {category}'**
  String allCategoryItems(String category);

  /// No description provided for @storeDescriptionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Discover products and services from this store.'**
  String get storeDescriptionPlaceholder;

  /// No description provided for @storeLocationPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Istanbul'**
  String get storeLocationPlaceholder;

  /// No description provided for @nearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get nearby;

  /// No description provided for @listingCount.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get listingCount;

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @views.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get views;

  /// No description provided for @discoverTab.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discoverTab;

  /// No description provided for @storeSloganLabel.
  ///
  /// In en, this message translates to:
  /// **'Slogan'**
  String get storeSloganLabel;

  /// No description provided for @listingVideoSection.
  ///
  /// In en, this message translates to:
  /// **'Product video'**
  String get listingVideoSection;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @mockNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'New activity'**
  String get mockNotificationTitle;

  /// No description provided for @mockNotificationDescription.
  ///
  /// In en, this message translates to:
  /// **'A seller sent you a message.'**
  String get mockNotificationDescription;

  /// No description provided for @mockMessagePreview.
  ///
  /// In en, this message translates to:
  /// **'I’m interested in this listing.'**
  String get mockMessagePreview;

  /// No description provided for @requiredName.
  ///
  /// In en, this message translates to:
  /// **'Enter your first and last name'**
  String get requiredName;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {count} characters long'**
  String passwordMinLength(int count);

  /// No description provided for @passwordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsMismatch;

  /// No description provided for @passwordResetComplete.
  ///
  /// In en, this message translates to:
  /// **'Password updated. You can now sign in.'**
  String get passwordResetComplete;

  /// No description provided for @passwordUnchangedHint.
  ///
  /// In en, this message translates to:
  /// **'Leave blank if you don\'t want to change it'**
  String get passwordUnchangedHint;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Profile could not be updated: {error}'**
  String profileUpdateFailed(String error);

  /// No description provided for @shortNumber.
  ///
  /// In en, this message translates to:
  /// **'Extension'**
  String get shortNumber;

  /// No description provided for @addContact.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addContact;

  /// No description provided for @invalidContactPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid contact phone number.'**
  String get invalidContactPhone;

  /// No description provided for @contactEmailAndPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an email address and contact phone number.'**
  String get contactEmailAndPhoneRequired;

  /// No description provided for @smsCodeSend.
  ///
  /// In en, this message translates to:
  /// **'Send SMS code'**
  String get smsCodeSend;

  /// No description provided for @notAdded.
  ///
  /// In en, this message translates to:
  /// **'Not added'**
  String get notAdded;

  /// No description provided for @storeStatusUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Store status could not be changed: {error}'**
  String storeStatusUpdateFailed(String error);

  /// No description provided for @storeDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Store could not be deleted: {error}'**
  String storeDeleteFailed(String error);

  /// No description provided for @storeApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get storeApproved;

  /// No description provided for @storeStatusApplication.
  ///
  /// In en, this message translates to:
  /// **'Awaiting approval'**
  String get storeStatusApplication;

  /// No description provided for @storeStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get storeStatusInactive;

  /// No description provided for @storeStatusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get storeStatusSuspended;

  /// No description provided for @storeStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get storeStatusRejected;

  /// No description provided for @storePendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Awaiting approval'**
  String get storePendingApproval;

  /// No description provided for @storePanelActive.
  ///
  /// In en, this message translates to:
  /// **'Your store panel is active. You can return to it at any time.'**
  String get storePanelActive;

  /// No description provided for @storeUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Your store is being reviewed. You can access the store panel after approval.'**
  String get storeUnderReview;

  /// No description provided for @paymentAwaiting.
  ///
  /// In en, this message translates to:
  /// **'Awaiting payment ({count})'**
  String paymentAwaiting(int count);

  /// No description provided for @listingRejectedTab.
  ///
  /// In en, this message translates to:
  /// **'Rejected ({count})'**
  String listingRejectedTab(int count);

  /// No description provided for @sortPriceLowest.
  ///
  /// In en, this message translates to:
  /// **'Lowest price'**
  String get sortPriceLowest;

  /// No description provided for @paymentError.
  ///
  /// In en, this message translates to:
  /// **'Payment error'**
  String get paymentError;

  /// No description provided for @profileViewCount.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get profileViewCount;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessages;

  /// No description provided for @regionAzerbaijan.
  ///
  /// In en, this message translates to:
  /// **'Azerbaijan'**
  String get regionAzerbaijan;

  /// No description provided for @regionTurkey.
  ///
  /// In en, this message translates to:
  /// **'Türkiye'**
  String get regionTurkey;

  /// No description provided for @lastSevenDays.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get lastSevenDays;

  /// No description provided for @lastThirtyDays.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get lastThirtyDays;

  /// No description provided for @searches.
  ///
  /// In en, this message translates to:
  /// **'Searches'**
  String get searches;

  /// No description provided for @messageSingular.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageSingular;

  /// No description provided for @activeListingsCount.
  ///
  /// In en, this message translates to:
  /// **'Active ({count})'**
  String activeListingsCount(int count);

  /// No description provided for @inactiveListingsCount.
  ///
  /// In en, this message translates to:
  /// **'Inactive ({count})'**
  String inactiveListingsCount(int count);

  /// No description provided for @moderationListingsCount.
  ///
  /// In en, this message translates to:
  /// **'Under review ({count})'**
  String moderationListingsCount(int count);

  /// No description provided for @storeDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get storeDeactivate;

  /// No description provided for @sellerLabel.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get sellerLabel;

  /// No description provided for @taxId.
  ///
  /// In en, this message translates to:
  /// **'Tax ID'**
  String get taxId;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @listingStateActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get listingStateActive;

  /// No description provided for @listingStateInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get listingStateInactive;

  /// No description provided for @listingStateRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get listingStateRejected;

  /// No description provided for @listingStateModeration.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get listingStateModeration;

  /// No description provided for @openingAt.
  ///
  /// In en, this message translates to:
  /// **'Opens at {time}'**
  String openingAt(String time);

  /// No description provided for @categoryCatalog.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get categoryCatalog;

  /// No description provided for @categoryVehicles.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get categoryVehicles;

  /// No description provided for @categoryHomeAppliances.
  ///
  /// In en, this message translates to:
  /// **'Home and appliances'**
  String get categoryHomeAppliances;

  /// No description provided for @categorySpecialClothing.
  ///
  /// In en, this message translates to:
  /// **'Special occasion clothing'**
  String get categorySpecialClothing;

  /// No description provided for @categoryRealEstate.
  ///
  /// In en, this message translates to:
  /// **'Real estate'**
  String get categoryRealEstate;

  /// No description provided for @categoryCosmetics.
  ///
  /// In en, this message translates to:
  /// **'Cosmetics'**
  String get categoryCosmetics;

  /// No description provided for @subcategoryComputers.
  ///
  /// In en, this message translates to:
  /// **'Computers'**
  String get subcategoryComputers;

  /// No description provided for @subcategoryTablets.
  ///
  /// In en, this message translates to:
  /// **'Tablets'**
  String get subcategoryTablets;

  /// No description provided for @subcategorySmartWatches.
  ///
  /// In en, this message translates to:
  /// **'Smart watches'**
  String get subcategorySmartWatches;

  /// No description provided for @subcategoryHeadphones.
  ///
  /// In en, this message translates to:
  /// **'Headphones'**
  String get subcategoryHeadphones;

  /// No description provided for @subcategoryTvAudio.
  ///
  /// In en, this message translates to:
  /// **'TV and audio'**
  String get subcategoryTvAudio;

  /// No description provided for @subcategoryGameConsoles.
  ///
  /// In en, this message translates to:
  /// **'Game consoles'**
  String get subcategoryGameConsoles;

  /// No description provided for @subcategoryAccessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get subcategoryAccessories;

  /// No description provided for @subcategoryCars.
  ///
  /// In en, this message translates to:
  /// **'Cars'**
  String get subcategoryCars;

  /// No description provided for @subcategoryMotorcycles.
  ///
  /// In en, this message translates to:
  /// **'Motorcycles'**
  String get subcategoryMotorcycles;

  /// No description provided for @subcategoryBicycles.
  ///
  /// In en, this message translates to:
  /// **'Bicycles'**
  String get subcategoryBicycles;

  /// No description provided for @subcategorySpareParts.
  ///
  /// In en, this message translates to:
  /// **'Spare parts'**
  String get subcategorySpareParts;

  /// No description provided for @subcategoryAutoParts.
  ///
  /// In en, this message translates to:
  /// **'Auto parts'**
  String get subcategoryAutoParts;

  /// No description provided for @subcategoryFurniture.
  ///
  /// In en, this message translates to:
  /// **'Furniture'**
  String get subcategoryFurniture;

  /// No description provided for @subcategoryHomeAppliances.
  ///
  /// In en, this message translates to:
  /// **'Home appliances'**
  String get subcategoryHomeAppliances;

  /// No description provided for @subcategoryKitchenware.
  ///
  /// In en, this message translates to:
  /// **'Kitchenware'**
  String get subcategoryKitchenware;

  /// No description provided for @subcategoryGardenLifestyle.
  ///
  /// In en, this message translates to:
  /// **'Garden and lifestyle'**
  String get subcategoryGardenLifestyle;

  /// No description provided for @subcategoryDecor.
  ///
  /// In en, this message translates to:
  /// **'Decor'**
  String get subcategoryDecor;

  /// No description provided for @subcategoryWomenClothing.
  ///
  /// In en, this message translates to:
  /// **'Women\'s clothing'**
  String get subcategoryWomenClothing;

  /// No description provided for @subcategoryMenClothing.
  ///
  /// In en, this message translates to:
  /// **'Men\'s clothing'**
  String get subcategoryMenClothing;

  /// No description provided for @subcategoryChildrenClothing.
  ///
  /// In en, this message translates to:
  /// **'Children\'s clothing'**
  String get subcategoryChildrenClothing;

  /// No description provided for @subcategoryShoes.
  ///
  /// In en, this message translates to:
  /// **'Shoes'**
  String get subcategoryShoes;

  /// No description provided for @subcategoryBags.
  ///
  /// In en, this message translates to:
  /// **'Bags'**
  String get subcategoryBags;

  /// No description provided for @subcategoryJewelry.
  ///
  /// In en, this message translates to:
  /// **'Jewelry'**
  String get subcategoryJewelry;

  /// No description provided for @subcategoryWatches.
  ///
  /// In en, this message translates to:
  /// **'Watches'**
  String get subcategoryWatches;

  /// No description provided for @subcategoryToys.
  ///
  /// In en, this message translates to:
  /// **'Toys'**
  String get subcategoryToys;

  /// No description provided for @subcategoryStrollers.
  ///
  /// In en, this message translates to:
  /// **'Strollers'**
  String get subcategoryStrollers;

  /// No description provided for @subcategoryChildFurniture.
  ///
  /// In en, this message translates to:
  /// **'Children\'s furniture'**
  String get subcategoryChildFurniture;

  /// No description provided for @subcategoryEducationBooks.
  ///
  /// In en, this message translates to:
  /// **'Education and books'**
  String get subcategoryEducationBooks;

  /// No description provided for @subcategoryApartments.
  ///
  /// In en, this message translates to:
  /// **'Apartments'**
  String get subcategoryApartments;

  /// No description provided for @subcategoryHouses.
  ///
  /// In en, this message translates to:
  /// **'Houses'**
  String get subcategoryHouses;

  /// No description provided for @subcategoryLand.
  ///
  /// In en, this message translates to:
  /// **'Land'**
  String get subcategoryLand;

  /// No description provided for @subcategoryCommercialProperty.
  ///
  /// In en, this message translates to:
  /// **'Commercial properties'**
  String get subcategoryCommercialProperty;

  /// No description provided for @subcategoryRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get subcategoryRent;

  /// No description provided for @subcategoryCosmetics.
  ///
  /// In en, this message translates to:
  /// **'Cosmetics and perfumes'**
  String get subcategoryCosmetics;

  /// No description provided for @subcategoryRepairServices.
  ///
  /// In en, this message translates to:
  /// **'Repair services'**
  String get subcategoryRepairServices;

  /// No description provided for @subcategoryEducationServices.
  ///
  /// In en, this message translates to:
  /// **'Education services'**
  String get subcategoryEducationServices;

  /// No description provided for @subcategoryBeautyServices.
  ///
  /// In en, this message translates to:
  /// **'Beauty services'**
  String get subcategoryBeautyServices;

  /// No description provided for @subcategoryOtherServices.
  ///
  /// In en, this message translates to:
  /// **'Other services'**
  String get subcategoryOtherServices;

  /// No description provided for @subcategorySportsShoes.
  ///
  /// In en, this message translates to:
  /// **'Sports shoes'**
  String get subcategorySportsShoes;

  /// No description provided for @subcategoryMusicalInstruments.
  ///
  /// In en, this message translates to:
  /// **'Musical instruments'**
  String get subcategoryMusicalInstruments;

  /// No description provided for @subcategoryBooks.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get subcategoryBooks;

  /// No description provided for @subcategoryCollectibles.
  ///
  /// In en, this message translates to:
  /// **'Collectibles'**
  String get subcategoryCollectibles;

  /// No description provided for @subcategoryVideoGames.
  ///
  /// In en, this message translates to:
  /// **'Video games'**
  String get subcategoryVideoGames;

  /// No description provided for @cityGanja.
  ///
  /// In en, this message translates to:
  /// **'Ganja'**
  String get cityGanja;

  /// No description provided for @citySumqayit.
  ///
  /// In en, this message translates to:
  /// **'Sumqayit'**
  String get citySumqayit;

  /// No description provided for @cityMingachevir.
  ///
  /// In en, this message translates to:
  /// **'Mingachevir'**
  String get cityMingachevir;

  /// No description provided for @cityLankaran.
  ///
  /// In en, this message translates to:
  /// **'Lankaran'**
  String get cityLankaran;

  /// No description provided for @sortPriceHighest.
  ///
  /// In en, this message translates to:
  /// **'Highest price'**
  String get sortPriceHighest;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @weekdayMondayShort.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMondayShort;

  /// No description provided for @weekdayTuesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTuesdayShort;

  /// No description provided for @weekdayWednesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWednesdayShort;

  /// No description provided for @weekdayThursdayShort.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThursdayShort;

  /// No description provided for @weekdayFridayShort.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFridayShort;

  /// No description provided for @weekdaySaturdayShort.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySaturdayShort;

  /// No description provided for @weekdaySundayShort.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySundayShort;

  /// No description provided for @rejectedListingsCount.
  ///
  /// In en, this message translates to:
  /// **'Rejected ({count})'**
  String rejectedListingsCount(int count);

  /// No description provided for @loginIdentifierRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number or email address'**
  String get loginIdentifierRequired;

  /// No description provided for @loginIdentifierInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number or email address'**
  String get loginIdentifierInvalid;

  /// No description provided for @invalidOtpCode.
  ///
  /// In en, this message translates to:
  /// **'The verification code is invalid.'**
  String get invalidOtpCode;

  /// No description provided for @accountAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'An account with these details already exists.'**
  String get accountAlreadyRegistered;

  /// No description provided for @authRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t complete this request. Please try again.'**
  String get authRequestFailed;

  /// No description provided for @serverTimeout.
  ///
  /// In en, this message translates to:
  /// **'The server took too long to respond. Please try again.'**
  String get serverTimeout;

  /// No description provided for @serverUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to the server. Check your connection and try again.'**
  String get serverUnavailable;

  /// No description provided for @requestFailed.
  ///
  /// In en, this message translates to:
  /// **'The request could not be completed. Please try again.'**
  String get requestFailed;

  /// No description provided for @storeNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Store name'**
  String get storeNameLabel;

  /// No description provided for @goToStore.
  ///
  /// In en, this message translates to:
  /// **'Go to store'**
  String get goToStore;

  /// No description provided for @backToPersonalAccount.
  ///
  /// In en, this message translates to:
  /// **'Back to personal account'**
  String get backToPersonalAccount;

  /// No description provided for @myStore.
  ///
  /// In en, this message translates to:
  /// **'My store'**
  String get myStore;

  /// No description provided for @listingStatusPendingPayment.
  ///
  /// In en, this message translates to:
  /// **'Awaiting payment'**
  String get listingStatusPendingPayment;

  /// No description provided for @listingStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get listingStatusInactive;

  /// No description provided for @listingStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get listingStatusRejected;

  /// No description provided for @listingStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get listingStatusExpired;

  /// No description provided for @listingStatusSold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get listingStatusSold;

  /// No description provided for @listingStatusDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get listingStatusDeleted;

  /// No description provided for @listingStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get listingStatusDraft;

  /// No description provided for @listingStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get listingStatusUnknown;

  /// No description provided for @listingStatusUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get listingStatusUnderReview;

  /// No description provided for @emptyActiveListings.
  ///
  /// In en, this message translates to:
  /// **'You have no active listings'**
  String get emptyActiveListings;

  /// No description provided for @emptyPendingPaymentListings.
  ///
  /// In en, this message translates to:
  /// **'You have no listings awaiting payment'**
  String get emptyPendingPaymentListings;

  /// No description provided for @emptyInactiveListings.
  ///
  /// In en, this message translates to:
  /// **'You have no inactive listings'**
  String get emptyInactiveListings;

  /// No description provided for @emptyRejectedListings.
  ///
  /// In en, this message translates to:
  /// **'You have no rejected listings'**
  String get emptyRejectedListings;

  /// No description provided for @emptyReviewListings.
  ///
  /// In en, this message translates to:
  /// **'You have no listings under review'**
  String get emptyReviewListings;

  /// No description provided for @postListingAction.
  ///
  /// In en, this message translates to:
  /// **'Post a listing'**
  String get postListingAction;

  /// No description provided for @storeDisableTemporarily.
  ///
  /// In en, this message translates to:
  /// **'Temporarily deactivate your store'**
  String get storeDisableTemporarily;

  /// No description provided for @storeEnableAgain.
  ///
  /// In en, this message translates to:
  /// **'Reactivate your store'**
  String get storeEnableAgain;

  /// No description provided for @storeHiddenDescription.
  ///
  /// In en, this message translates to:
  /// **'Customers won\'t be able to see your store or listings. You can reactivate them at any time.'**
  String get storeHiddenDescription;

  /// No description provided for @storeVisibleDescription.
  ///
  /// In en, this message translates to:
  /// **'Your store and listings will be visible to customers again.'**
  String get storeVisibleDescription;

  /// No description provided for @storeDisableAction.
  ///
  /// In en, this message translates to:
  /// **'Deactivate store'**
  String get storeDisableAction;

  /// No description provided for @storeEnableAction.
  ///
  /// In en, this message translates to:
  /// **'Activate store'**
  String get storeEnableAction;

  /// No description provided for @storeVisibilityHelp.
  ///
  /// In en, this message translates to:
  /// **'Preview how customers see your store.'**
  String get storeVisibilityHelp;

  /// No description provided for @viewMyStore.
  ///
  /// In en, this message translates to:
  /// **'View my store'**
  String get viewMyStore;

  /// No description provided for @storeEnableConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reactivate your store?'**
  String get storeEnableConfirm;

  /// No description provided for @storeDisableConfirm.
  ///
  /// In en, this message translates to:
  /// **'Deactivate your store?'**
  String get storeDisableConfirm;

  /// No description provided for @storeEnableConfirmDescription.
  ///
  /// In en, this message translates to:
  /// **'Customers will be able to see your store again.'**
  String get storeEnableConfirmDescription;

  /// No description provided for @storeDisableConfirmDescription.
  ///
  /// In en, this message translates to:
  /// **'Your store and listings will be hidden temporarily.'**
  String get storeDisableConfirmDescription;

  /// No description provided for @shareListingTitle.
  ///
  /// In en, this message translates to:
  /// **'Share {seller}\'s listing'**
  String shareListingTitle(String seller);

  /// No description provided for @shareAction.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareAction;

  /// No description provided for @copyLinkAction.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLinkAction;

  /// No description provided for @shareListingText.
  ///
  /// In en, this message translates to:
  /// **'Check out {seller}\'s listing: {link}'**
  String shareListingText(String seller, String link);

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @dayAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String dayAgo(int count);

  /// No description provided for @savedListingsTab.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get savedListingsTab;

  /// No description provided for @savedSearchesTab.
  ///
  /// In en, this message translates to:
  /// **'Searches'**
  String get savedSearchesTab;

  /// No description provided for @followedStoresTab.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get followedStoresTab;

  /// No description provided for @sortRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get sortRecommended;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @minimumPrice.
  ///
  /// In en, this message translates to:
  /// **'Minimum price'**
  String get minimumPrice;

  /// No description provided for @maximumPrice.
  ///
  /// In en, this message translates to:
  /// **'Maximum price'**
  String get maximumPrice;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get applyFilters;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetFilters;

  /// No description provided for @businessStoreName.
  ///
  /// In en, this message translates to:
  /// **'Store name'**
  String get businessStoreName;

  /// No description provided for @storeLogoTitle.
  ///
  /// In en, this message translates to:
  /// **'Store logo'**
  String get storeLogoTitle;

  /// No description provided for @storeBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Store banner'**
  String get storeBannerTitle;

  /// No description provided for @businessEditAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get businessEditAddress;

  /// No description provided for @businessContactNumber.
  ///
  /// In en, this message translates to:
  /// **'Contact number'**
  String get businessContactNumber;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @storeInfo.
  ///
  /// In en, this message translates to:
  /// **'Store profile'**
  String get storeInfo;

  /// No description provided for @businessWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get businessWallet;

  /// No description provided for @businessEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get businessEditProfile;

  /// No description provided for @businessSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get businessSettings;

  /// No description provided for @storeUnderReviewEmpty.
  ///
  /// In en, this message translates to:
  /// **'You have no listings under review'**
  String get storeUnderReviewEmpty;

  /// No description provided for @openNow.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get openNow;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @sortLowestPrice.
  ///
  /// In en, this message translates to:
  /// **'Lowest price'**
  String get sortLowestPrice;

  /// No description provided for @sortHighestPrice.
  ///
  /// In en, this message translates to:
  /// **'Highest price'**
  String get sortHighestPrice;

  /// No description provided for @sortNewestListings.
  ///
  /// In en, this message translates to:
  /// **'Newest listings'**
  String get sortNewestListings;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String hoursAgo(int count);

  /// No description provided for @storeLogoHint.
  ///
  /// In en, this message translates to:
  /// **'PNG displayed on your store page and catalog, 500 × 500 px'**
  String get storeLogoHint;

  /// No description provided for @storeBannerHint.
  ///
  /// In en, this message translates to:
  /// **'PNG displayed on your store page and catalog, 2000 × 532 px'**
  String get storeBannerHint;

  /// No description provided for @slogan.
  ///
  /// In en, this message translates to:
  /// **'Slogan'**
  String get slogan;

  /// No description provided for @cityIstanbul.
  ///
  /// In en, this message translates to:
  /// **'Istanbul'**
  String get cityIstanbul;

  /// No description provided for @districtNarimanov.
  ///
  /// In en, this message translates to:
  /// **'Narimanov'**
  String get districtNarimanov;

  /// No description provided for @districtSahil.
  ///
  /// In en, this message translates to:
  /// **'Sahil'**
  String get districtSahil;

  /// No description provided for @districtYasamal.
  ///
  /// In en, this message translates to:
  /// **'Yasamal'**
  String get districtYasamal;

  /// No description provided for @districtGanjlik.
  ///
  /// In en, this message translates to:
  /// **'Ganjlik'**
  String get districtGanjlik;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @paymentMethodCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get paymentMethodCard;

  /// No description provided for @paymentMethodBankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get paymentMethodBankTransfer;

  /// No description provided for @topUpInvoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Invoice: {number}'**
  String topUpInvoiceNumber(String number);

  /// No description provided for @checkPaymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Check payment status'**
  String get checkPaymentStatus;

  /// No description provided for @walletInsufficientBalance.
  ///
  /// In en, this message translates to:
  /// **'Your wallet balance is insufficient. Top up your wallet to continue.'**
  String get walletInsufficientBalance;

  /// No description provided for @freeDailyPromotions.
  ///
  /// In en, this message translates to:
  /// **'{count} free promotions available today'**
  String freeDailyPromotions(int count);

  /// No description provided for @sellerType.
  ///
  /// In en, this message translates to:
  /// **'Seller type'**
  String get sellerType;

  /// No description provided for @individual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get individual;

  /// No description provided for @store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get store;

  /// No description provided for @listingCreatedActive.
  ///
  /// In en, this message translates to:
  /// **'Your listing is active'**
  String get listingCreatedActive;

  /// No description provided for @listingCreatedActiveDescription.
  ///
  /// In en, this message translates to:
  /// **'Your product is now available to customers.'**
  String get listingCreatedActiveDescription;

  /// No description provided for @listingCreatedVideoFailed.
  ///
  /// In en, this message translates to:
  /// **'Your listing was created, but its video could not be attached.'**
  String get listingCreatedVideoFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
