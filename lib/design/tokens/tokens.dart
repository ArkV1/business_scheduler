import 'package:mix/mix.dart';

const $token = AppThemeToken();

class AppThemeToken {
  const AppThemeToken();
  final color = const AppColorToken();
  final textStyle = const AppTextStyleToken();
  final spacing = const AppSpaceToken();
  final radius = const AppRadiusToken();
}

class AppColorToken {
  const AppColorToken();
  
  // Brand Colors
  ColorToken get primary => const ColorToken('color.primary');
  ColorToken get onPrimary => const ColorToken('color.onPrimary');
  ColorToken get surface => const ColorToken('color.surface');
  ColorToken get onSurface => const ColorToken('color.onSurface');
  ColorToken get background => const ColorToken('color.background');
  ColorToken get card => const ColorToken('color.card');
  ColorToken get border => const ColorToken('color.border');
}

class AppTextStyleToken {
  const AppTextStyleToken();
  
  TextStyleToken get displayLarge => const TextStyleToken('text.displayLarge');
  TextStyleToken get displayMedium => const TextStyleToken('text.displayMedium');
  TextStyleToken get displaySmall => const TextStyleToken('text.displaySmall');
  TextStyleToken get headlineLarge => const TextStyleToken('text.headlineLarge');
  TextStyleToken get headlineMedium => const TextStyleToken('text.headlineMedium');
  TextStyleToken get headlineSmall => const TextStyleToken('text.headlineSmall');
  TextStyleToken get titleLarge => const TextStyleToken('text.titleLarge');
  TextStyleToken get titleMedium => const TextStyleToken('text.titleMedium');
  TextStyleToken get titleSmall => const TextStyleToken('text.titleSmall');
  TextStyleToken get bodyLarge => const TextStyleToken('text.bodyLarge');
  TextStyleToken get bodyMedium => const TextStyleToken('text.bodyMedium');
  TextStyleToken get bodySmall => const TextStyleToken('text.bodySmall');
  TextStyleToken get labelLarge => const TextStyleToken('text.labelLarge');
  TextStyleToken get labelMedium => const TextStyleToken('text.labelMedium');
  TextStyleToken get labelSmall => const TextStyleToken('text.labelSmall');
}

class AppSpaceToken {
  const AppSpaceToken();
  
  SpaceToken get small => const SpaceToken('space.small');
  SpaceToken get medium => const SpaceToken('space.medium');
  SpaceToken get large => const SpaceToken('space.large');
}

class AppRadiusToken {
  const AppRadiusToken();
  
  RadiusToken get small => const RadiusToken('radius.small');
  RadiusToken get medium => const RadiusToken('radius.medium');
  RadiusToken get large => const RadiusToken('radius.large');
}