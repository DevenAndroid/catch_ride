import 'package:flutter/material.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/utils/date_picker_helper.dart';

// ── Mock data ──────────────────────────────────────────────────────────────

final List<Map<String, dynamic>> _monthlyRevenue = [
  {'month': 'Sep', 'amount': 1200.0},
  {'month': 'Oct', 'amount': 2800.0},
  {'month': 'Nov', 'amount': 2100.0},
  {'month': 'Dec', 'amount': 3400.0},
  {'month': 'Jan', 'amount': 2950.0},
  {'month': 'Feb', 'amount': 1750.0},
];

final List<Map<String, dynamic>> _recentTransactions = [
  {
    'client': 'Sarah Williams',
    'service': 'Full Day Grooming',
    'date': DateTime(2026, 2, 18),
    'amount': 200.0,
    'status': 'completed',
  },
  {
    'client': 'Emily Johnson',
    'service': 'Braiding (Mane + Tail)',
    'date': DateTime(2026, 2, 16),
    'amount': 65.0,
    'status': 'completed',
  },
  {
    'client': 'Michael Davis',
    'service': 'Full Body Clipping',
    'date': DateTime(2026, 2, 14),
    'amount': 150.0,
    'status': 'completed',
  },
  {
    'client': 'Lisa Chen',
    'service': 'Full Day Grooming',
    'date': DateTime(2026, 2, 12),
    'amount': 200.0,
    'status': 'pending',
  },
  {
    'client': 'Rachel Brooks',
    'service': 'Show Prep (Half Day)',
    'date': DateTime(2026, 2, 10),
    'amount': 120.0,
    'status': 'completed',
  },
];

final List<Map<String, dynamic>> _serviceBreakdown = [
  {
    'service': 'Full Day Grooming',
    'total': 4200.0,
    'count': 21,
    'percent': 0.55,
  },
  {'service': 'Braiding', 'total': 1625.0, 'count': 25, 'percent': 0.21},
  {
    'service': 'Full Body Clipping',
    'total': 1200.0,
    'count': 8,
    'percent': 0.16,
  },
  {'service': 'Show Prep', 'total': 600.0, 'count': 5, 'percent': 0.08},
];

final List<Map<String, dynamic>> _payoutHistory = [
  {'date': DateTime(2026, 2, 15), 'amount': 1450.0, 'status': 'paid'},
  {'date': DateTime(2026, 2, 1), 'amount': 1325.0, 'status': 'paid'},
  {'date': DateTime(2026, 1, 15), 'amount': 980.0, 'status': 'paid'},
];

// ── Screen ─────────────────────────────────────────────────────────────────

class VendorEarningsScreen extends StatefulWidget {
  const VendorEarningsScreen({super.key});

  @override
  State<VendorEarningsScreen> createState() => _VendorEarningsScreenState();
}

class _VendorEarningsScreenState extends State<VendorEarningsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'This Month';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings & Stats'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.deepNavy,
          unselectedLabelColor: AppColors.grey500,
          indicatorColor: AppColors.mutedGold,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Transactions'),
            Tab(text: 'Payouts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildTransactionsTab(),
          _buildPayoutsTab(),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  TAB 1 – Overview
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Period Selector ───
          _buildPeriodSelector(),
          const SizedBox(height: 20),

          // ─── Headline Earning Card ───
          _buildEarningHeadlineCard(),
          const SizedBox(height: 16),

          // ─── Stats Row ───
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle_outline,
                  label: 'Jobs Done',
                  value: '59',
                  color: AppColors.successGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.star_outline,
                  label: 'Avg Rating',
                  value: '4.8',
                  color: AppColors.mutedGold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people_outline,
                  label: 'Repeat %',
                  value: '72%',
                  color: AppColors.deepNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ─── Monthly Revenue Chart ───
          Text('Monthly Revenue', style: AppTextStyles.titleLarge),
          const SizedBox(height: 16),
          _buildRevenueChart(),
          const SizedBox(height: 28),

          // ─── Earnings by Service ───
          Text('Earnings by Service', style: AppTextStyles.titleLarge),
          const SizedBox(height: 16),
          ..._serviceBreakdown.map(_buildServiceBreakdownRow),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['This Week', 'This Month', 'This Year', 'All Time'];
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: periods.length,
        itemBuilder: (context, index) {
          final p = periods[index];
          final isSelected = _selectedPeriod == p;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(p),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedPeriod = p),
              selectedColor: AppColors.deepNavy,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.deepNavy,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected ? AppColors.deepNavy : AppColors.grey300,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEarningHeadlineCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.deepNavy, Color(0xFF1A3A5C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.mutedGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.mutedGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Total Earnings',
                style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '\$7,625.00',
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.trending_up,
                  color: AppColors.successGreen,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '+18.5% vs last month',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Quick summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniSummary('Pending', '\$200.00', Colors.white70),
              _buildMiniSummary('Available', '\$5,975.00', AppColors.mutedGold),
              _buildMiniSummary(
                'Paid Out',
                '\$1,450.00',
                AppColors.successGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniSummary(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              fontSize: 22,
              color: AppColors.deepNavy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.grey600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Revenue Chart (custom painted bars) ─────────────────────────────────

  Widget _buildRevenueChart() {
    final maxAmount = _monthlyRevenue.fold<double>(
      0,
      (a, b) => a > (b['amount'] as double) ? a : b['amount'] as double,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _monthlyRevenue.map((data) {
                final amount = data['amount'] as double;
                final ratio = amount / maxAmount;
                final isCurrentMonth = data['month'] == 'Feb';

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '\$${(amount / 1000).toStringAsFixed(1)}k',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 10,
                            color: isCurrentMonth
                                ? AppColors.deepNavy
                                : AppColors.grey500,
                            fontWeight: isCurrentMonth
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: 140 * ratio,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isCurrentMonth
                                  ? [
                                      AppColors.mutedGold,
                                      const Color(0xFFDAC07A),
                                    ]
                                  : [
                                      AppColors.deepNavy,
                                      const Color(0xFF1A3A5C),
                                    ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Month labels
          Row(
            children: _monthlyRevenue.map((data) {
              final isCurrentMonth = data['month'] == 'Feb';
              return Expanded(
                child: Center(
                  child: Text(
                    data['month'] as String,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isCurrentMonth
                          ? AppColors.deepNavy
                          : AppColors.grey500,
                      fontWeight: isCurrentMonth
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── Service Breakdown Row ───────────────────────────────────────────────

  Widget _buildServiceBreakdownRow(Map<String, dynamic> data) {
    final percent = data['percent'] as double;
    final colors = [
      AppColors.deepNavy,
      AppColors.mutedGold,
      AppColors.successGreen,
      const Color(0xFF5C8CB5),
    ];
    final colorIndex = _serviceBreakdown.indexOf(data);
    final barColor = colors[colorIndex % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    data['service'] as String,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '\$${(data['total'] as double).toStringAsFixed(0)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepNavy,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${data['count']} jobs)',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: AppColors.grey200,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(percent * 100).toInt()}%',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.grey500,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  TAB 2 – Transactions
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildTransactionsTab() {
    return Column(
      children: [
        // Summary strip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: AppColors.grey50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_recentTransactions.length} transactions',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey600,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Total: ',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  Text(
                    '\$735.00',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.deepNavy,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _recentTransactions.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final tx = _recentTransactions[index];
              return _buildTransactionTile(tx);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> tx) {
    final status = tx['status'] as String;
    final isPending = status == 'pending';
    final date = tx['date'] as DateTime;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: isPending
                ? AppColors.mutedGold.withOpacity(0.15)
                : AppColors.successGreen.withOpacity(0.1),
            child: Icon(
              isPending ? Icons.hourglass_top : Icons.check,
              color: isPending ? AppColors.mutedGold : AppColors.successGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx['client'] as String,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tx['service'] as String,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppDateFormatter.dateOnly.format(date),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Amount + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+\$${(tx['amount'] as double).toStringAsFixed(0)}',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.deepNavy,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPending
                      ? AppColors.mutedGold.withOpacity(0.12)
                      : AppColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isPending ? 'Pending' : 'Completed',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isPending
                        ? AppColors.mutedGold
                        : AppColors.successGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  TAB 3 – Payouts
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildPayoutsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Payout summary card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.grey200),
            // Shadow removed to prevent RenderPhysicalShape issues
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available for Payout',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$5,975.00',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.deepNavy,
                          fontSize: 28,
                        ),
                      ),
                    ],
                  ),
                  // Custom button to avoid Material RenderPhysicalShape crash
                  GestureDetector(
                    onTap: () => _showRequestPayoutSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.deepNavy,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Request',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Manual divider
              Container(height: 1, color: AppColors.grey200),
              const SizedBox(height: 12),
              // Bank account info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      size: 20,
                      color: AppColors.deepNavy,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chase Bank •••• 4821',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Payouts every 2 weeks',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Payout History
        Text('Payout History', style: AppTextStyles.titleLarge),
        const SizedBox(height: 16),
        ..._payoutHistory.map(_buildPayoutHistoryRow),

        const SizedBox(height: 32),

        // Year-to-date summary
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.warmCream,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Year-to-Date Summary',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.deepNavy,
                ),
              ),
              const SizedBox(height: 16),
              _buildYTDRow('Total Earned', '\$7,625.00'),
              _buildYTDRow('Total Paid Out', '\$3,755.00'),
              _buildYTDRow('Platform Fees (15%)', '-\$1,143.75'),
              Container(
                height: 1,
                color: const Color(0xFFE0E0E0),
                margin: const EdgeInsets.symmetric(vertical: 12),
              ),
              _buildYTDRow('Net Earnings', '\$6,481.25', isBold: true),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildPayoutHistoryRow(Map<String, dynamic> payout) {
    final date = payout['date'] as DateTime;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_downward,
              color: AppColors.successGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bank Transfer',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppDateFormatter.dateOnly.format(date),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${(payout['amount'] as double).toStringAsFixed(2)}',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.successGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Paid',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYTDRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold
                ? AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)
                : AppTextStyles.bodyMedium.copyWith(color: AppColors.grey700),
          ),
          Text(
            value,
            style: isBold
                ? AppTextStyles.titleMedium.copyWith(
                    color: AppColors.deepNavy,
                    fontWeight: FontWeight.bold,
                  )
                : AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepNavy,
                  ),
          ),
        ],
      ),
    );
  }

  // ─── Request Payout Bottom Sheet ─────────────────────────────────────────

  void _showRequestPayoutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Icon(
                Icons.account_balance_wallet,
                size: 48,
                color: AppColors.deepNavy,
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Request Payout',
                  style: AppTextStyles.headlineMedium,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Available: \$5,975.00',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Funds will be transferred to your linked bank account within 3-5 business days.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey600,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payout requested successfully!'),
                      backgroundColor: AppColors.successGreen,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Confirm Payout',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
