import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'empty_state.dart';

/// AppScaffoldWithList - Scaffold template cho list screens
class AppScaffoldWithList extends StatelessWidget {
  final String title;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool isEmpty;
  final String emptyMessage;
  final IconData emptyIcon;
  final List<Widget>? actions;
  final Widget Function(BuildContext context) itemBuilder;
  final int itemCount;
  final Widget? floatingActionButton;
  final VoidCallback? onRefresh;

  const AppScaffoldWithList({
    super.key,
    required this.title,
    required this.isLoading,
    required this.hasError,
    this.errorMessage,
    this.onRetry,
    required this.isEmpty,
    required this.emptyMessage,
    required this.emptyIcon,
    this.actions,
    required this.itemBuilder,
    required this.itemCount,
    this.floatingActionButton,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: _buildBody(),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildBody() {
    if (isLoading && isEmpty) {
      return const LoadingState();
    }

    if (hasError) {
      return ErrorState(
        message: errorMessage ?? 'Đã xảy ra lỗi',
        onRetry: onRetry,
      );
    }

    if (isEmpty) {
      return EmptyState(
        icon: emptyIcon,
        message: emptyMessage,
      );
    }

    final list = ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: itemCount,
      itemBuilder: (context, index) => itemBuilder(context),
    );

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: () async => onRefresh!(),
        child: list,
      );
    }

    return list;
  }
}

/// FormScaffold - Scaffold template cho form screens
class FormScaffold extends StatelessWidget {
  final String title;
  final GlobalKey<FormState> formKey;
  final List<Widget> fields;
  final String submitLabel;
  final VoidCallback onSubmit;
  final bool isLoading;
  final List<Widget>? actions;

  const FormScaffold({
    super.key,
    required this.title,
    required this.formKey,
    required this.fields,
    required this.submitLabel,
    required this.onSubmit,
    this.isLoading = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...fields,
              SizedBox(height: AppSpacing.xl),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onSubmit,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(submitLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
