// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ResEvent {
  Object get field0;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ResEvent &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @override
  String toString() {
    return 'ResEvent(field0: $field0)';
  }
}

/// @nodoc
class $ResEventCopyWith<$Res> {
  $ResEventCopyWith(ResEvent _, $Res Function(ResEvent) __);
}

/// Adds pattern-matching-related methods to [ResEvent].
extension ResEventPatterns on ResEvent {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ResEvent_ScannerEvent value)? scannerEvent,
    TResult Function(ResEvent_CompareEvent value)? compareEvent,
    TResult Function(ResEvent_DoneEvent value)? doneEvent,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case ResEvent_ScannerEvent() when scannerEvent != null:
        return scannerEvent(_that);
      case ResEvent_CompareEvent() when compareEvent != null:
        return compareEvent(_that);
      case ResEvent_DoneEvent() when doneEvent != null:
        return doneEvent(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ResEvent_ScannerEvent value) scannerEvent,
    required TResult Function(ResEvent_CompareEvent value) compareEvent,
    required TResult Function(ResEvent_DoneEvent value) doneEvent,
  }) {
    final _that = this;
    switch (_that) {
      case ResEvent_ScannerEvent():
        return scannerEvent(_that);
      case ResEvent_CompareEvent():
        return compareEvent(_that);
      case ResEvent_DoneEvent():
        return doneEvent(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ResEvent_ScannerEvent value)? scannerEvent,
    TResult? Function(ResEvent_CompareEvent value)? compareEvent,
    TResult? Function(ResEvent_DoneEvent value)? doneEvent,
  }) {
    final _that = this;
    switch (_that) {
      case ResEvent_ScannerEvent() when scannerEvent != null:
        return scannerEvent(_that);
      case ResEvent_CompareEvent() when compareEvent != null:
        return compareEvent(_that);
      case ResEvent_DoneEvent() when doneEvent != null:
        return doneEvent(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ScannerEvent field0)? scannerEvent,
    TResult Function(CompareEvent field0)? compareEvent,
    TResult Function(DoneEvent field0)? doneEvent,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case ResEvent_ScannerEvent() when scannerEvent != null:
        return scannerEvent(_that.field0);
      case ResEvent_CompareEvent() when compareEvent != null:
        return compareEvent(_that.field0);
      case ResEvent_DoneEvent() when doneEvent != null:
        return doneEvent(_that.field0);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ScannerEvent field0) scannerEvent,
    required TResult Function(CompareEvent field0) compareEvent,
    required TResult Function(DoneEvent field0) doneEvent,
  }) {
    final _that = this;
    switch (_that) {
      case ResEvent_ScannerEvent():
        return scannerEvent(_that.field0);
      case ResEvent_CompareEvent():
        return compareEvent(_that.field0);
      case ResEvent_DoneEvent():
        return doneEvent(_that.field0);
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ScannerEvent field0)? scannerEvent,
    TResult? Function(CompareEvent field0)? compareEvent,
    TResult? Function(DoneEvent field0)? doneEvent,
  }) {
    final _that = this;
    switch (_that) {
      case ResEvent_ScannerEvent() when scannerEvent != null:
        return scannerEvent(_that.field0);
      case ResEvent_CompareEvent() when compareEvent != null:
        return compareEvent(_that.field0);
      case ResEvent_DoneEvent() when doneEvent != null:
        return doneEvent(_that.field0);
      case _:
        return null;
    }
  }
}

/// @nodoc

class ResEvent_ScannerEvent extends ResEvent {
  const ResEvent_ScannerEvent(this.field0) : super._();

  @override
  final ScannerEvent field0;

  /// Create a copy of ResEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ResEvent_ScannerEventCopyWith<ResEvent_ScannerEvent> get copyWith =>
      _$ResEvent_ScannerEventCopyWithImpl<ResEvent_ScannerEvent>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ResEvent_ScannerEvent &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'ResEvent.scannerEvent(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $ResEvent_ScannerEventCopyWith<$Res>
    implements $ResEventCopyWith<$Res> {
  factory $ResEvent_ScannerEventCopyWith(ResEvent_ScannerEvent value,
          $Res Function(ResEvent_ScannerEvent) _then) =
      _$ResEvent_ScannerEventCopyWithImpl;
  @useResult
  $Res call({ScannerEvent field0});
}

/// @nodoc
class _$ResEvent_ScannerEventCopyWithImpl<$Res>
    implements $ResEvent_ScannerEventCopyWith<$Res> {
  _$ResEvent_ScannerEventCopyWithImpl(this._self, this._then);

  final ResEvent_ScannerEvent _self;
  final $Res Function(ResEvent_ScannerEvent) _then;

  /// Create a copy of ResEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(ResEvent_ScannerEvent(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as ScannerEvent,
    ));
  }
}

/// @nodoc

class ResEvent_CompareEvent extends ResEvent {
  const ResEvent_CompareEvent(this.field0) : super._();

  @override
  final CompareEvent field0;

  /// Create a copy of ResEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ResEvent_CompareEventCopyWith<ResEvent_CompareEvent> get copyWith =>
      _$ResEvent_CompareEventCopyWithImpl<ResEvent_CompareEvent>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ResEvent_CompareEvent &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'ResEvent.compareEvent(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $ResEvent_CompareEventCopyWith<$Res>
    implements $ResEventCopyWith<$Res> {
  factory $ResEvent_CompareEventCopyWith(ResEvent_CompareEvent value,
          $Res Function(ResEvent_CompareEvent) _then) =
      _$ResEvent_CompareEventCopyWithImpl;
  @useResult
  $Res call({CompareEvent field0});
}

/// @nodoc
class _$ResEvent_CompareEventCopyWithImpl<$Res>
    implements $ResEvent_CompareEventCopyWith<$Res> {
  _$ResEvent_CompareEventCopyWithImpl(this._self, this._then);

  final ResEvent_CompareEvent _self;
  final $Res Function(ResEvent_CompareEvent) _then;

  /// Create a copy of ResEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(ResEvent_CompareEvent(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as CompareEvent,
    ));
  }
}

/// @nodoc

class ResEvent_DoneEvent extends ResEvent {
  const ResEvent_DoneEvent(this.field0) : super._();

  @override
  final DoneEvent field0;

  /// Create a copy of ResEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ResEvent_DoneEventCopyWith<ResEvent_DoneEvent> get copyWith =>
      _$ResEvent_DoneEventCopyWithImpl<ResEvent_DoneEvent>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ResEvent_DoneEvent &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'ResEvent.doneEvent(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $ResEvent_DoneEventCopyWith<$Res>
    implements $ResEventCopyWith<$Res> {
  factory $ResEvent_DoneEventCopyWith(
          ResEvent_DoneEvent value, $Res Function(ResEvent_DoneEvent) _then) =
      _$ResEvent_DoneEventCopyWithImpl;
  @useResult
  $Res call({DoneEvent field0});
}

/// @nodoc
class _$ResEvent_DoneEventCopyWithImpl<$Res>
    implements $ResEvent_DoneEventCopyWith<$Res> {
  _$ResEvent_DoneEventCopyWithImpl(this._self, this._then);

  final ResEvent_DoneEvent _self;
  final $Res Function(ResEvent_DoneEvent) _then;

  /// Create a copy of ResEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(ResEvent_DoneEvent(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as DoneEvent,
    ));
  }
}

// dart format on
