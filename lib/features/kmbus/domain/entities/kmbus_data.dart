import 'package:equatable/equatable.dart';

class KmbusData extends Equatable {
  final KmbusStatus? status;
  final int? id;
  final int? selisih;
  final KmbusBus? bus;
  final KmbusKoridor? koridor;
  final KmbusPramugara? pramugara;
  final String? code;
  final double ritaseKe;
  final KmbusShift? shift;
  final String? tanggalKm;
  final int? titikAwal;
  final int? titikAkhir;
  final int? totalDiakui;
  final int? totalTempuh;

  const KmbusData({
    this.status,
    this.id,
    this.selisih,
    this.bus,
    this.koridor,
    this.pramugara,
    this.code,
    required this.ritaseKe,
    this.shift,
    this.tanggalKm,
    this.titikAwal,
    this.titikAkhir,
    this.totalDiakui,
    this.totalTempuh,
  });

  factory KmbusData.fromJson(Map<String, dynamic> json) {
    return KmbusData(
      status: json['status'] != null ? KmbusStatus.fromJson(json['status']) : null,
      id: json['id'],
      selisih: json['selisih'],
      bus: json['bus'] != null ? KmbusBus.fromJson(json['bus']) : null,
      koridor: json['koridor'] != null ? KmbusKoridor.fromJson(json['koridor']) : null,
      pramugara: json['pramugara'] != null ? KmbusPramugara.fromJson(json['pramugara']) : null,
      code: json['code'],
      ritaseKe: (json['ritaseKe'] ?? 0).toDouble(),
      shift: json['shift'] != null ? KmbusShift.fromJson(json['shift']) : null,
      tanggalKm: json['tanggalKm'],
      titikAwal: json['titikAwal'],
      titikAkhir: json['titikAkhir'],
      totalDiakui: json['totalDiakui'],
      totalTempuh: json['totalTempuh'],
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status?.toJson(),
    "id": id,
    "selisih": selisih,
    "bus": bus?.toJson(),
    "koridor": koridor?.toJson(),
    "pramugara": pramugara?.toJson(),
    "code": code,
    "ritaseKe": ritaseKe,
    "shift": shift?.toJson(),
    "tanggalKm": tanggalKm,
    "titikAwal": titikAwal,
    "titikAkhir": titikAkhir,
    "totalDiakui": totalDiakui,
    "totalTempuh": totalTempuh,
  };

  KmbusData copyWith({
    KmbusStatus? status,
    int? id,
    int? selisih,
    KmbusBus? bus,
    KmbusKoridor? koridor,
    KmbusPramugara? pramugara,
    String? code,
    double? ritaseKe,
    KmbusShift? shift,
    String? tanggalKm,
    int? titikAwal,
    int? titikAkhir,
    int? totalDiakui,
    int? totalTempuh,
  }) {
    return KmbusData(
      status: status ?? this.status,
      id: id ?? this.id,
      selisih: selisih ?? this.selisih,
      bus: bus ?? this.bus,
      koridor: koridor ?? this.koridor,
      pramugara: pramugara ?? this.pramugara,
      code: code ?? this.code,
      ritaseKe: ritaseKe ?? this.ritaseKe,
      shift: shift ?? this.shift,
      tanggalKm: tanggalKm ?? this.tanggalKm,
      titikAwal: titikAwal ?? this.titikAwal,
      titikAkhir: titikAkhir ?? this.titikAkhir,
      totalDiakui: totalDiakui ?? this.totalDiakui,
      totalTempuh: totalTempuh ?? this.totalTempuh,
    );
  }

  @override
  List<Object?> get props => [
    status,
    id,
    selisih,
    bus,
    koridor,
    pramugara,
    code,
    ritaseKe,
    shift,
    tanggalKm,
    titikAwal,
    titikAkhir,
    totalDiakui,
    totalTempuh,
  ];
}

class KmbusStatus extends Equatable {
  final String? name;
  final int? id;
  final String? code;

  const KmbusStatus({this.name, this.id, this.code});

  factory KmbusStatus.fromJson(Map<String, dynamic> json) => KmbusStatus(
    name: json['name'],
    id: json['id'],
    code: json['code'],
  );

  Map<String, dynamic> toJson() => {"name": name, "id": id, "code": code};

  @override
  List<Object?> get props => [name, id, code];
}

class KmbusBus extends Equatable {
  final int? id;
  final String? platNomor;
  final String? nomorLambung;

  const KmbusBus({this.id, this.platNomor, this.nomorLambung});

  factory KmbusBus.fromJson(Map<String, dynamic> json) => KmbusBus(
    id: json['id'],
    platNomor: json['platNomor'],
    nomorLambung: json['nomorLambung'],
  );

  Map<String, dynamic> toJson() => {"id": id, "platNomor": platNomor, "nomorLambung": nomorLambung};

  @override
  List<Object?> get props => [id, platNomor, nomorLambung];
}

class KmbusKoridor extends Equatable {
  final String? name;
  final int? id;
  final String? code;

  const KmbusKoridor({this.name, this.id, this.code});

  factory KmbusKoridor.fromJson(Map<String, dynamic> json) => KmbusKoridor(
    name: json['name'],
    id: json['id'],
    code: json['code'],
  );

  Map<String, dynamic> toJson() => {"name": name, "id": id, "code": code};

  @override
  List<Object?> get props => [name, id, code];
}

class KmbusPramugara extends Equatable {
  final int? id;
  final String? fullName;

  const KmbusPramugara({this.id, this.fullName});

  factory KmbusPramugara.fromJson(Map<String, dynamic> json) => KmbusPramugara(
    id: json['id'],
    fullName: json['fullName'],
  );

  Map<String, dynamic> toJson() => {"id": id, "fullName": fullName};

  @override
  List<Object?> get props => [id, fullName];
}

class KmbusShift extends Equatable {
  final String? name;
  final int? id;
  final String? code;

  const KmbusShift({this.name, this.id, this.code});

  factory KmbusShift.fromJson(Map<String, dynamic> json) => KmbusShift(
    name: json['name'],
    id: json['id'],
    code: json['code'],
  );

  Map<String, dynamic> toJson() => {"name": name, "id": id, "code": code};

  @override
  List<Object?> get props => [name, id, code];
}