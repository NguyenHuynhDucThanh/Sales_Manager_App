# Theme System - Hướng dẫn sử dụng

## Cấu trúc

```
lib/theme/
├── app_colors.dart      # Bảng màu chuẩn
├── app_text_styles.dart # Typography
└── app_theme.dart       # Theme configuration + Utilities
```

## Cách sử dụng

### 1. Import theme vào file

```dart
import 'package:sales_manager_app/theme/app_colors.dart';
import 'package:sales_manager_app/theme/app_text_styles.dart';
import 'package:sales_manager_app/theme/app_theme.dart';
```

### 2. Sử dụng màu sắc (AppColors)

```dart
// Primary colors
Container(color: AppColors.primary)
Text('Hello', style: TextStyle(color: AppColors.textPrimary))

// Semantic colors
Icon(Icons.check, color: AppColors.success)
Icon(Icons.warning, color: AppColors.warning)
Icon(Icons.error, color: AppColors.error)

// Status colors
Container(color: AppColors.pending)     // Đơn hàng chờ
Container(color: AppColors.confirmed)   // Đơn hàng đã xác nhận
Container(color: AppColors.cancelled)   // Đơn hàng đã hủy

// Gradient
Container(decoration: BoxDecoration(gradient: AppColors.primaryGradient))
```

### 3. Sử dụng text styles (AppTextStyles)

```dart
// Headings
Text('Title', style: AppTextStyles.h1)
Text('Subtitle', style: AppTextStyles.h2)
Text('Section', style: AppTextStyles.h3)

// Body text
Text('Content', style: AppTextStyles.bodyLarge)
Text('Paragraph', style: AppTextStyles.bodyMedium)
Text('Small text', style: AppTextStyles.bodySmall)

// Labels
Text('Label', style: AppTextStyles.label)
Text('Small label', style: AppTextStyles.labelSmall)

// Price (màu đỏ, bold)
Text('100.000đ', style: AppTextStyles.price)
Text('50.000đ', style: AppTextStyles.priceSmall)

// Caption / Hint
Text('Hint text', style: AppTextStyles.caption)

// Custom với copyWith()
Text('Custom', style: AppTextStyles.h2.copyWith(
  color: AppColors.primary,
  fontSize: 28,
))
```

### 4. Sử dụng Decoration (AppDecoration)

```dart
// Card với shadow
Container(decoration: AppDecoration.card)

// Card flat (border thay vì shadow)
Container(decoration: AppDecoration.cardFlat)

// Gradient background
Container(decoration: AppDecoration.gradient)

// Status badges
Container(decoration: AppDecoration.statusPending)    // Vàng
Container(decoration: AppDecoration.statusConfirmed)  // Xanh lá
Container(decoration: AppDecoration.statusCancelled)  // Đỏ
```

### 5. Sử dụng Spacing (AppSpacing)

```dart
SizedBox(height: AppSpacing.xs)   // 4px
SizedBox(height: AppSpacing.sm)   // 8px
SizedBox(height: AppSpacing.md)   // 16px (default)
SizedBox(height: AppSpacing.lg)   // 24px
SizedBox(height: AppSpacing.xl)   // 32px
SizedBox(height: AppSpacing.xxl)  // 48px

// Padding
Padding(padding: EdgeInsets.all(AppSpacing.md))
Padding(padding: EdgeInsets.symmetric(
  horizontal: AppSpacing.md,
  vertical: AppSpacing.sm,
))
```

### 6. Sử dụng Border Radius (AppRadius)

```dart
BorderRadius.circular(AppRadius.sm)   // 8px
BorderRadius.circular(AppRadius.md)   // 12px (default)
BorderRadius.circular(AppRadius.lg)   // 16px
BorderRadius.circular(AppRadius.xl)   // 24px
BorderRadius.circular(AppRadius.full) // 999px (fully rounded)
```

## Ví dụ hoàn chỉnh

### Card sản phẩm với theme

```dart
Card(
  elevation: 3,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
  ),
  child: Padding(
    padding: EdgeInsets.all(AppSpacing.md),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tên sản phẩm', style: AppTextStyles.h4),
        SizedBox(height: AppSpacing.sm),
        Text('Mô tả', style: AppTextStyles.bodySmall),
        SizedBox(height: AppSpacing.md),
        Text('100.000đ', style: AppTextStyles.price),
      ],
    ),
  ),
)
```

### Button với theme

```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    padding: EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
  ),
  child: Text('Xác nhận', style: AppTextStyles.button),
)
```

### Status badge

```dart
Container(
  padding: EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.sm,
  ),
  decoration: AppDecoration.statusConfirmed,
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.check_circle, size: 16, color: AppColors.confirmed),
      SizedBox(width: AppSpacing.xs),
      Text(
        'Đã xác nhận',
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.confirmed,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
)
```

## Lợi ích

✅ **Nhất quán**: Tất cả màn hình dùng cùng design system
✅ **Dễ maintain**: Thay đổi 1 chỗ, ảnh hưởng toàn bộ app
✅ **Responsive**: Spacing và sizing được chuẩn hóa
✅ **Professional**: Giao diện đẹp, chuyên nghiệp hơn
✅ **Reusable**: Các decoration, style tái sử dụng được

## Khi nào cần custom?

Chỉ custom khi có yêu cầu đặc biệt, không nằm trong theme:

```dart
// Ví dụ: Màu đặc biệt cho 1 trường hợp
Text(
  'Special case',
  style: AppTextStyles.bodyMedium.copyWith(
    color: const Color(0xFFFF5722), // Custom color
    fontStyle: FontStyle.italic,
  ),
)
```

Nhưng nên cân nhắc thêm vào theme nếu dùng nhiều lần!
