import 'package:flutter/material.dart';
import 'package:sprints_payment_task/processor.dart';

class PaymentHomePage extends StatefulWidget {
  const PaymentHomePage({super.key, required this.title});

  final String title;

  @override
  State<PaymentHomePage> createState() => _PaymentHomePageState();
}

class _PaymentHomePageState extends State<PaymentHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isProcessing = false;
  String _resultMessage = '';
  bool _paymentSuccess = false;

  Future<void> _handlePayment(PaymentProcessor processor) async {
    if (!_formKey.currentState!.validate()) return;
    
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _isProcessing = true;
      _resultMessage = '';
    });

    try {
      final success = await processor.processPayment(amount);
      setState(() {
        _paymentSuccess = success;
        _resultMessage = success ? 'Payment Successful!' : 'Payment Failed!';
      });
    } catch (e) {
      setState(() {
        _paymentSuccess = false;
        _resultMessage = 'Payment Error: ${e.toString()}';
      });
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPaymentForm(),
            const SizedBox(height: 32),
            _buildPaymentMethods(),
            const SizedBox(height: 24),
            _buildResultIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Amount',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 16),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Choose Payment Method',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 20),
        if (_isProcessing)
          const Center(child: CircularProgressIndicator())
        else ...[
          FilledButton.icon(
            icon: const Icon(Icons.wallet),
            label: const Text('Cash Payment'),
            onPressed: () => _handlePayment(CashPaymentProcessor()),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.deepPurple.shade400,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            icon: const Icon(Icons.credit_card_rounded),
            label: const Text('Credit Card'),
            onPressed: () => _handlePayment(CreditPaymentProcessor()),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.teal.shade400,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResultIndicator() {
    if (_resultMessage.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _paymentSuccess ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            _paymentSuccess ? Icons.check_circle : Icons.error,
            color: _paymentSuccess ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _resultMessage,
              style: TextStyle(
                color: _paymentSuccess ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}