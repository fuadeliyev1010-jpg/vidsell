// TODO(api): grouping inferred from response order; remove when the backend exposes the category<->subcategory mapping.
const Map<String, List<String>> subcategoryCategoryMap = {
  'ELECTRONICS': ['PHONES', 'COMPUTERS', 'TABLETS', 'TV_AUDIO', 'ACCESSORIES'],
  'TRANSPORT': ['CARS', 'MOTORCYCLES', 'BICYCLES', 'SPARE_PARTS'],
  'REAL_ESTATE': ['APARTMENTS', 'HOUSES', 'LANDS', 'COMMERCIAL'],
  'HOME_APPLIANCES': [
    'REFRIGERATORS',
    'WASHING_MACHINES',
    'AIR_CONDITIONERS',
    'KITCHEN_APPLIANCES',
  ],
  'SPECIAL_OCCASION': ['WEDDING', 'CEREMONY', 'NATIONAL_CLOTHING'],
  'COSMETICS': ['PERFUME', 'SKINCARE', 'MAKEUP', 'HAIRCARE'],
};
