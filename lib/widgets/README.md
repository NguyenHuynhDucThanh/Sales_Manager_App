# Widgets Library - Hướng dẫn sử dụng

## Cấu trúc

```
lib/widgets/
├── widgets.dart          # Export tất cả widgets (import file này)
├── app_button.dart       # Buttons (Primary, Outline, Text)
├── app_card.dart         # Cards & Containers
├── app_text_field.dart   # Text fields
├── status_badge.dart     # Status badges (pending, confirmed, cancelled)
├── empty_state.dart      # Empty/Loading/Error states
└── product_card.dart     # Product cards
```

## Import

```dart
// Import tất cả widgets một lần
import 'package:sales_manager_app/widgets/widgets.dart';
```

## 1. Buttons (AppButton, AppOutlineButton, AppTextButton)

### AppButton - Primary Button

```dart
// Button cơ bản
AppButton(
  label: 'Đăng nhập',
  onPressed: () {},
)

// Button với icon
AppButton(
  label: 'Thêm vào giỏ',
  icon: Icons.shopping_cart,
  onPressed: () {},
)

// Button đang loading
AppButton(
  label: 'Đang xử lý...',
  isLoading: true,
  onPressed: () {},
)

// Button custom màu
AppButton(
  label: 'Xóa',
  backgroundColor: AppColors.error,
  icon: Icons.delete,
  onPressed: () {},
)
```

### AppOutlineButton - Outline Button

```dart
AppOutlineButton(
  label: 'Đăng ký',
  onPressed: () {},
)

// Với icon
AppOutlineButton(
  label: 'Quay lại',
  icon: Icons.arrow_back,
  onPressed: () {},
)
```

### AppTextButton - Text Button

```dart
AppTextButton(
  label: 'Bỏ qua',
  onPressed: () {},
)
```

## 2. Cards (AppCard, AppContainer)

### AppCard - Card component

```dart
// Card cơ bản
AppCard(
  child: Text('Nội dung'),
)

// Card có thể click
AppCard(
  onTap: () {
    // Navigate
  },
  child: Column(
    children: [
      Text('Title'),
      Text('Description'),
    ],
  ),
)

// Custom padding và elevation
AppCard(
  padding: EdgeInsets.all(AppSpacing.lg),
  elevation: 4,
  child: Text('Content'),
)
```

### AppContainer - Container với decoration

```dart
// Container với gradient
AppContainer.gradient(
  child: Text('Hero banner'),
)

// Container với decoration tùy chỉnh
AppContainer(
  decoration: AppDecoration.card,
  padding: EdgeInsets.all(AppSpacing.md),
  child: Text('Content'),
)
```

## 3. Text Field (AppTextField)

```dart
// TextField cơ bản
AppTextField(
  controller: emailController,
  labelText: 'Email',
  hintText: 'Nhập email của bạn',
  prefixIcon: Icons.email,
)

// Password field
AppTextField(
  controller: passwordController,
  labelText: 'Mật khẩu',
  obscureText: true,
  prefixIcon: Icons.lock,
)

// TextField với validation
AppTextField(
  controller: controller,
  labelText: 'Họ tên',
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập họ tên';
    }
    return null;
  },
)

// Multi-line text field
AppTextField(
  controller: descriptionController,
  labelText: 'Mô tả',
  maxLines: 5,
)
```

## 4. Status Badges

### StatusBadge - Badge trạng thái đơn hàng

```dart
// Pending
StatusBadge(
  status: 'pending',
  label: 'Chờ xác nhận',
)

// Confirmed
StatusBadge(
  status: 'confirmed',
  label: 'Đã xác nhận',
)

// Cancelled
StatusBadge(
  status: 'cancelled',
  label: 'Đã hủy',
)
```

### StockBadge - Badge trạng thái kho

```dart
// Còn hàng
StockBadge(inStock: true)

// Hết hàng
StockBadge(inStock: false)

// Custom label
StockBadge(
  inStock: true,
  customLabel: 'Còn ${product.stock} sản phẩm',
)
```

## 5. Empty/Loading/Error States

### EmptyState - Trạng thái trống

```dart
// Empty state cơ bản
EmptyState(
  icon: Icons.shopping_cart_outlined,
  message: 'Giỏ hàng trống',
)

// Với action button
EmptyState(
  icon: Icons.inventory_2_outlined,
  message: 'Chưa có sản phẩm nào',
  actionLabel: 'Thêm sản phẩm',
  onAction: () {
    // Navigate to add product
  },
)
```

### LoadingState - Loading indicator

```dart
// Loading cơ bản
LoadingState()

// Với message
LoadingState(message: 'Đang tải dữ liệu...')
```

### ErrorState - Trạng thái lỗi

```dart
// Error với retry
ErrorState(
  message: 'Không thể tải dữ liệu',
  onRetry: () {
    // Retry logic
  },
)
```

## 6. Product Cards

### ProductCard - Card sản phẩm (Grid view)

```dart
ProductCard(
  product: product,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  },
  trailing: StockBadge(inStock: product.stock > 0),
)
```

### ProductListTile - List item sản phẩm (Admin)

```dart
// Với swipe to delete
ProductListTile(
  product: product,
  onTap: () {
    // Edit product
  },
  onDelete: () async {
    await viewModel.deleteProduct(product.id);
  },
)

// Không có delete
ProductListTile(
  product: product,
  onTap: () {},
)
```

## Ví dụ: Refactor màn hình với widgets

### BEFORE (Code dài)

```dart
Card(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        Text('Title', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Description'),
      ],
    ),
  ),
)
```

### AFTER (Sử dụng widget)

```dart
AppCard(
  child: Column(
    children: [
      Text('Title', style: AppTextStyles.h4),
      SizedBox(height: AppSpacing.sm),
      Text('Description', style: AppTextStyles.bodyMedium),
    ],
  ),
)
```

## Lợi ích

✅ **Code ngắn gọn**: Giảm boilerplate code
✅ **Tái sử dụng**: Widgets dùng lại nhiều nơi
✅ **Dễ maintain**: Sửa 1 chỗ, ảnh hưởng toàn bộ
✅ **Consistent**: Giao diện nhất quán
✅ **Type-safe**: Có validation và type checking

## Best Practices

1. **Luôn dùng widgets có sẵn** thay vì viết lại
2. **Custom khi cần thiết** bằng cách extend hoặc compose
3. **Đặt tên rõ ràng** cho các custom widgets
4. **Document** các props và use cases
5. **Test** widgets riêng biệt
