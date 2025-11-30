import 'event_model.dart';
import 'user_model.dart';

class TicketModel {
  final String id;
  final String userId;
  final String eventId;
  final String paymentId;
  final int ticketCount;
  final String tierLabel;
  final double amountPaid;
  final String ticketNumber;
  final String? qrCode;
  final String status; // 'active', 'used', 'cancelled'
  final EventModel? event;
  final PaymentInfo? payment;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TicketModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.paymentId,
    this.ticketCount = 1,
    required this.tierLabel,
    required this.amountPaid,
    required this.ticketNumber,
    this.qrCode,
    this.status = 'active',
    this.event,
    this.payment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    EventModel? event;
    String eventIdStr = '';
    if (json['eventId'] != null) {
      if (json['eventId'] is Map) {
        event = EventModel.fromJson(json['eventId']);
        eventIdStr = event.id;
      } else {
        eventIdStr = json['eventId'].toString();
      }
    }

    PaymentInfo? payment;
    String paymentIdStr = '';
    if (json['paymentId'] != null) {
      if (json['paymentId'] is Map) {
        payment = PaymentInfo.fromJson(json['paymentId']);
        paymentIdStr = payment.id;
      } else {
        paymentIdStr = json['paymentId'].toString();
      }
    }

    return TicketModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId']?.toString() ?? '',
      eventId: eventIdStr,
      paymentId: paymentIdStr,
      ticketCount: json['ticketCount'] ?? 1,
      tierLabel: json['tierLabel'] ?? '',
      amountPaid: (json['amountPaid'] ?? 0).toDouble(),
      ticketNumber: json['ticketNumber'] ?? '',
      qrCode: json['qrCode'],
      status: json['status'] ?? 'active',
      event: event,
      payment: payment,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'eventId': eventId,
      'paymentId': paymentId,
      'ticketCount': ticketCount,
      'tierLabel': tierLabel,
      'amountPaid': amountPaid,
      'ticketNumber': ticketNumber,
      'qrCode': qrCode,
      'status': status,
      'event': event?.toJson(),
      'payment': payment?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isActive => status == 'active';
  bool get isUsed => status == 'used';
  bool get isCancelled => status == 'cancelled';
}

class PaymentInfo {
  final String id;
  final double amount;
  final String refId;
  final DateTime createdAt;

  const PaymentInfo({
    required this.id,
    required this.amount,
    required this.refId,
    required this.createdAt,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      refId: json['refId'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'amount': amount,
      'refId': refId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

