import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/total_bar.dart';
import '../../../cart/domain/entities/cart.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../bloc/payment_bloc.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  void _onPaymentState(BuildContext context, PaymentState state) {
    switch (state) {
      case PaymentSuccess(:final receipt):
        Navigator.of(
          context,
        ).pushReplacementNamed(AppRoutes.paymentSuccess, arguments: receipt);
        context.read<CartBloc>().add(const LoadCart());
      case PaymentError(:final message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
      case PaymentInitial() || PaymentProcessing():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentBloc, PaymentState>(
      listener: _onPaymentState,
      builder: (context, payment) {
        final processing = payment is PaymentProcessing;
        final cart = context.watch<CartBloc>().state.cart;

        return PopScope(
          canPop: !processing,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Checkout'),
              bottom: processing
                  ? const PreferredSize(
                      preferredSize: Size.fromHeight(4),
                      child: LinearProgressIndicator(),
                    )
                  : null,
            ),
            body: switch (payment) {
              PaymentSuccess() => const LoadingView(),
              _ when cart.isEmpty => const EmptyStateView(
                icon: Icons.shopping_bag_outlined,
                title: 'Nothing to pay for',
                message: 'Your cart is empty.',
              ),
              _ => _OrderSummary(cart: cart, processing: processing),
            },
            bottomNavigationBar: cart.isEmpty || payment is PaymentSuccess
                ? null
                : TotalBar(
                    label: 'Total payable',
                    amount: cart.totalAmount,
                    actionLabel: 'Pay now',
                    isLoading: processing,
                    onPressed: () => context.read<PaymentBloc>().add(
                      const InitiatePayment(),
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.cart, required this.processing});

  final Cart cart;
  final bool processing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Order summary', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (final item in cart.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.product.name}  ×${item.quantity}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(formatPrice(item.lineTotal)),
                      ],
                    ),
                  ),
                const Divider(height: 20),
                _SummaryRow(
                  label: 'Items',
                  value: '${cart.totalItems}',
                  style: muted,
                ),
                _SummaryRow(
                  label: 'Subtotal',
                  value: formatPrice(cart.totalAmount),
                  style: muted,
                ),
                _SummaryRow(label: 'Delivery', value: 'Free', style: muted),
                const Divider(height: 20),
                _SummaryRow(
                  label: 'Total payable',
                  value: formatPrice(cart.totalAmount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(
              processing ? Icons.hourglass_top : Icons.lock_outline,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                processing
                    ? 'Processing your payment…'
                    : 'Simulated payment. No real money is charged.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.style});

  final String label;
  final String value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
