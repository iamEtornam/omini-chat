import 'package:equatable/equatable.dart';

/// Model information entity
class ModelInfo extends Equatable {
  final String name;
  final ModelStatus status;

  const ModelInfo({required this.name, this.status = ModelStatus.notLoaded});

  /// Copy with new values
  ModelInfo copyWith({String? name, ModelStatus? status}) {
    return ModelInfo(name: name ?? this.name, status: status ?? this.status);
  }

  @override
  List<Object?> get props => [name, status];
}

/// Model status
enum ModelStatus { notLoaded, loading, ready, error }
