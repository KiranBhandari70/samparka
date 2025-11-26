class RewardTransaction {
  final String id;
  final String userId;
  final String type; // 'earned' or 'redeemed'
  final String source; // 'ticket_purchase', 'event_attendance', etc.
  final int amount;
  final String description;
  final String? relatedEventId;
  final String? relatedPaymentId;
  final RewardMetadata? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RewardTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.source,
    required this.amount,
    required this.description,
    this.relatedEventId,
    this.relatedPaymentId,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RewardTransaction.fromJson(Map<String, dynamic> json) {
    return RewardTransaction(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      source: json['source'] ?? '',
      amount: (json['amount'] ?? 0).toInt(),
      description: json['description'] ?? '',
      relatedEventId: json['relatedEventId'],
      relatedPaymentId: json['relatedPaymentId'],
      metadata: json['metadata'] != null 
          ? RewardMetadata.fromJson(json['metadata'])
          : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'type': type,
      'source': source,
      'amount': amount,
      'description': description,
      'relatedEventId': relatedEventId,
      'relatedPaymentId': relatedPaymentId,
      'metadata': metadata?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isEarned => type == 'earned';
  bool get isRedeemed => type == 'redeemed';

  String get formattedAmount => isEarned ? '+$amount' : '-$amount';
  
  String get displayTitle {
    switch (source) {
      case 'ticket_purchase':
        return 'Points Earned';
      case 'event_attendance':
        return 'Event Attendance';
      case 'event_hosting':
        return 'Event Hosting';
      case 'partner_redemption':
        return 'Points Redeemed';
      case 'admin_adjustment':
        return 'Admin Adjustment';
      default:
        return isEarned ? 'Points Earned' : 'Points Redeemed';
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

class RewardMetadata {
  final double? ticketAmount;
  final int? ticketCount;
  final String? tierLabel;
  final String? partnerName;
  final String? adminNote;

  const RewardMetadata({
    this.ticketAmount,
    this.ticketCount,
    this.tierLabel,
    this.partnerName,
    this.adminNote,
  });

  factory RewardMetadata.fromJson(Map<String, dynamic> json) {
    return RewardMetadata(
      ticketAmount: json['ticketAmount']?.toDouble(),
      ticketCount: json['ticketCount']?.toInt(),
      tierLabel: json['tierLabel'],
      partnerName: json['partnerName'],
      adminNote: json['adminNote'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticketAmount': ticketAmount,
      'ticketCount': ticketCount,
      'tierLabel': tierLabel,
      'partnerName': partnerName,
      'adminNote': adminNote,
    };
  }
}

class RewardDashboardData {
  final int balance;
  final int monthlyEarned;
  final int totalEarned;
  final int totalRedeemed;
  final List<RewardTransaction> recentActivity;

  const RewardDashboardData({
    required this.balance,
    required this.monthlyEarned,
    required this.totalEarned,
    required this.totalRedeemed,
    required this.recentActivity,
  });

  factory RewardDashboardData.fromJson(Map<String, dynamic> json) {
    return RewardDashboardData(
      balance: (json['balance'] ?? 0).toInt(),
      monthlyEarned: (json['monthlyEarned'] ?? 0).toInt(),
      totalEarned: (json['totalEarned'] ?? 0).toInt(),
      totalRedeemed: (json['totalRedeemed'] ?? 0).toInt(),
      recentActivity: (json['recentActivity'] as List<dynamic>? ?? [])
          .map((item) => RewardTransaction.fromJson(item))
          .toList(),
    );
  }
}
