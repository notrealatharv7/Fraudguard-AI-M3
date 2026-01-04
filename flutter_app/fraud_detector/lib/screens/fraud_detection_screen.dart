import 'package:flutter/material.dart';
import 'package:fraud_detector/services/api_service.dart';
import 'package:fraud_detector/models/transaction_input.dart';
import 'package:fraud_detector/models/fraud_prediction.dart';

/// Main screen for fraud detection
/// Contains form inputs and displays prediction results
class FraudDetectionScreen extends StatefulWidget {
  const FraudDetectionScreen({super.key});

  @override
  State<FraudDetectionScreen> createState() => _FraudDetectionScreenState();
}

class _FraudDetectionScreenState extends State<FraudDetectionScreen> {
  // Form controllers for all 6 input fields
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _amountDeviationController = TextEditingController();
  final _timeAnomalyController = TextEditingController();
  final _locationDistanceController = TextEditingController();
  final _merchantNoveltyController = TextEditingController();
  final _frequencyController = TextEditingController();

  // State variables
  bool _isLoading = false;
  FraudPrediction? _prediction;
  String? _errorMessage;

  // API service instance
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    // Clean up controllers
    _amountController.dispose();
    _amountDeviationController.dispose();
    _timeAnomalyController.dispose();
    _locationDistanceController.dispose();
    _merchantNoveltyController.dispose();
    _frequencyController.dispose();
    super.dispose();
  }

  /// Validates and submits the form to the API
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _prediction = null;
      _errorMessage = null;
    });

    try {
      // Create transaction input from form data
      final transaction = TransactionInput(
        transactionAmount: double.parse(_amountController.text),
        transactionAmountDeviation: double.parse(_amountDeviationController.text),
        timeAnomaly: double.parse(_timeAnomalyController.text),
        locationDistance: double.parse(_locationDistanceController.text),
        merchantNovelty: double.parse(_merchantNoveltyController.text),
        transactionFrequency: double.parse(_frequencyController.text),
      );

      // Call API to get prediction
      final prediction = await _apiService.predictFraud(transaction);

      setState(() {
        _prediction = prediction;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fraud Detection System'),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Input form card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction Details',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      // Transaction Amount
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Transaction Amount',
                          hintText: 'e.g., 150.50',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter transaction amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      // Amount Deviation
                      TextFormField(
                        controller: _amountDeviationController,
                        decoration: const InputDecoration(
                          labelText: 'Amount Deviation',
                          hintText: 'e.g., 0.25',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.trending_up),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter amount deviation';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      // Time Anomaly
                      TextFormField(
                        controller: _timeAnomalyController,
                        decoration: const InputDecoration(
                          labelText: 'Time Anomaly (0-1)',
                          hintText: 'e.g., 0.3',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter time anomaly';
                          }
                          final val = double.tryParse(value);
                          if (val == null || val < 0 || val > 1) {
                            return 'Must be between 0 and 1';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      // Location Distance
                      TextFormField(
                        controller: _locationDistanceController,
                        decoration: const InputDecoration(
                          labelText: 'Location Distance',
                          hintText: 'e.g., 25.0',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter location distance';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      // Merchant Novelty
                      TextFormField(
                        controller: _merchantNoveltyController,
                        decoration: const InputDecoration(
                          labelText: 'Merchant Novelty (0-1)',
                          hintText: 'e.g., 0.2',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.store),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter merchant novelty';
                          }
                          final val = double.tryParse(value);
                          if (val == null || val < 0 || val > 1) {
                            return 'Must be between 0 and 1';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      // Transaction Frequency
                      TextFormField(
                        controller: _frequencyController,
                        decoration: const InputDecoration(
                          labelText: 'Transaction Frequency',
                          hintText: 'e.g., 5',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.repeat),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter transaction frequency';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Check for Fraud',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Result display card
              if (_prediction != null) _buildResultCard(),
              // Error display
              if (_errorMessage != null) _buildErrorCard(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the result card showing fraud prediction
  Widget _buildResultCard() {
    final isFraud = _prediction!.fraud;
    final riskScore = _prediction!.riskScore;
    final riskPercentage = (riskScore * 100).toStringAsFixed(1);

    return Card(
      elevation: 4,
      color: isFraud ? Colors.red.shade50 : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Status icon
            Icon(
              isFraud ? Icons.warning : Icons.check_circle,
              size: 64,
              color: isFraud ? Colors.red : Colors.green,
            ),
            const SizedBox(height: 16),
            // Status text
            Text(
              isFraud ? 'FRAUD DETECTED' : 'LEGITIMATE TRANSACTION',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isFraud ? Colors.red.shade700 : Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 12),
            // Risk score
            Text(
              'Risk Score: $riskPercentage%',
              style: TextStyle(
                fontSize: 20,
                color: isFraud ? Colors.red.shade600 : Colors.green.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            // Risk bar
            LinearProgressIndicator(
              value: riskScore,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                isFraud ? Colors.red : Colors.green,
              ),
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the error card for displaying API errors
  Widget _buildErrorCard() {
    return Card(
      elevation: 4,
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.orange.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


