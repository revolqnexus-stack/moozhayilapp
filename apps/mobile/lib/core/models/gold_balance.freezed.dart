// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gold_balance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GoldRateUsed {

 String get purity;@JsonKey(name: 'rate_paise') int get ratePaise;@JsonKey(name: 'rate_display') String get rateDisplay;@JsonKey(name: 'updated_at') String get updatedAt;@JsonKey(name: 'is_stale') bool? get isStale;@JsonKey(name: 'stale_after_seconds') int? get staleAfterSeconds;
/// Create a copy of GoldRateUsed
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoldRateUsedCopyWith<GoldRateUsed> get copyWith => _$GoldRateUsedCopyWithImpl<GoldRateUsed>(this as GoldRateUsed, _$identity);

  /// Serializes this GoldRateUsed to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoldRateUsed&&(identical(other.purity, purity) || other.purity == purity)&&(identical(other.ratePaise, ratePaise) || other.ratePaise == ratePaise)&&(identical(other.rateDisplay, rateDisplay) || other.rateDisplay == rateDisplay)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isStale, isStale) || other.isStale == isStale)&&(identical(other.staleAfterSeconds, staleAfterSeconds) || other.staleAfterSeconds == staleAfterSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,purity,ratePaise,rateDisplay,updatedAt,isStale,staleAfterSeconds);

@override
String toString() {
  return 'GoldRateUsed(purity: $purity, ratePaise: $ratePaise, rateDisplay: $rateDisplay, updatedAt: $updatedAt, isStale: $isStale, staleAfterSeconds: $staleAfterSeconds)';
}


}

/// @nodoc
abstract mixin class $GoldRateUsedCopyWith<$Res>  {
  factory $GoldRateUsedCopyWith(GoldRateUsed value, $Res Function(GoldRateUsed) _then) = _$GoldRateUsedCopyWithImpl;
@useResult
$Res call({
 String purity,@JsonKey(name: 'rate_paise') int ratePaise,@JsonKey(name: 'rate_display') String rateDisplay,@JsonKey(name: 'updated_at') String updatedAt,@JsonKey(name: 'is_stale') bool? isStale,@JsonKey(name: 'stale_after_seconds') int? staleAfterSeconds
});




}
/// @nodoc
class _$GoldRateUsedCopyWithImpl<$Res>
    implements $GoldRateUsedCopyWith<$Res> {
  _$GoldRateUsedCopyWithImpl(this._self, this._then);

  final GoldRateUsed _self;
  final $Res Function(GoldRateUsed) _then;

/// Create a copy of GoldRateUsed
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? purity = null,Object? ratePaise = null,Object? rateDisplay = null,Object? updatedAt = null,Object? isStale = freezed,Object? staleAfterSeconds = freezed,}) {
  return _then(_self.copyWith(
purity: null == purity ? _self.purity : purity // ignore: cast_nullable_to_non_nullable
as String,ratePaise: null == ratePaise ? _self.ratePaise : ratePaise // ignore: cast_nullable_to_non_nullable
as int,rateDisplay: null == rateDisplay ? _self.rateDisplay : rateDisplay // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,isStale: freezed == isStale ? _self.isStale : isStale // ignore: cast_nullable_to_non_nullable
as bool?,staleAfterSeconds: freezed == staleAfterSeconds ? _self.staleAfterSeconds : staleAfterSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [GoldRateUsed].
extension GoldRateUsedPatterns on GoldRateUsed {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoldRateUsed value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoldRateUsed() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoldRateUsed value)  $default,){
final _that = this;
switch (_that) {
case _GoldRateUsed():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoldRateUsed value)?  $default,){
final _that = this;
switch (_that) {
case _GoldRateUsed() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String purity, @JsonKey(name: 'rate_paise')  int ratePaise, @JsonKey(name: 'rate_display')  String rateDisplay, @JsonKey(name: 'updated_at')  String updatedAt, @JsonKey(name: 'is_stale')  bool? isStale, @JsonKey(name: 'stale_after_seconds')  int? staleAfterSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoldRateUsed() when $default != null:
return $default(_that.purity,_that.ratePaise,_that.rateDisplay,_that.updatedAt,_that.isStale,_that.staleAfterSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String purity, @JsonKey(name: 'rate_paise')  int ratePaise, @JsonKey(name: 'rate_display')  String rateDisplay, @JsonKey(name: 'updated_at')  String updatedAt, @JsonKey(name: 'is_stale')  bool? isStale, @JsonKey(name: 'stale_after_seconds')  int? staleAfterSeconds)  $default,) {final _that = this;
switch (_that) {
case _GoldRateUsed():
return $default(_that.purity,_that.ratePaise,_that.rateDisplay,_that.updatedAt,_that.isStale,_that.staleAfterSeconds);case _:
  throw StateError('Unexpected subclass');

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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String purity, @JsonKey(name: 'rate_paise')  int ratePaise, @JsonKey(name: 'rate_display')  String rateDisplay, @JsonKey(name: 'updated_at')  String updatedAt, @JsonKey(name: 'is_stale')  bool? isStale, @JsonKey(name: 'stale_after_seconds')  int? staleAfterSeconds)?  $default,) {final _that = this;
switch (_that) {
case _GoldRateUsed() when $default != null:
return $default(_that.purity,_that.ratePaise,_that.rateDisplay,_that.updatedAt,_that.isStale,_that.staleAfterSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoldRateUsed implements GoldRateUsed {
  const _GoldRateUsed({required this.purity, @JsonKey(name: 'rate_paise') required this.ratePaise, @JsonKey(name: 'rate_display') required this.rateDisplay, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'is_stale') this.isStale, @JsonKey(name: 'stale_after_seconds') this.staleAfterSeconds});
  factory _GoldRateUsed.fromJson(Map<String, dynamic> json) => _$GoldRateUsedFromJson(json);

@override final  String purity;
@override@JsonKey(name: 'rate_paise') final  int ratePaise;
@override@JsonKey(name: 'rate_display') final  String rateDisplay;
@override@JsonKey(name: 'updated_at') final  String updatedAt;
@override@JsonKey(name: 'is_stale') final  bool? isStale;
@override@JsonKey(name: 'stale_after_seconds') final  int? staleAfterSeconds;

/// Create a copy of GoldRateUsed
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoldRateUsedCopyWith<_GoldRateUsed> get copyWith => __$GoldRateUsedCopyWithImpl<_GoldRateUsed>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoldRateUsedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoldRateUsed&&(identical(other.purity, purity) || other.purity == purity)&&(identical(other.ratePaise, ratePaise) || other.ratePaise == ratePaise)&&(identical(other.rateDisplay, rateDisplay) || other.rateDisplay == rateDisplay)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isStale, isStale) || other.isStale == isStale)&&(identical(other.staleAfterSeconds, staleAfterSeconds) || other.staleAfterSeconds == staleAfterSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,purity,ratePaise,rateDisplay,updatedAt,isStale,staleAfterSeconds);

@override
String toString() {
  return 'GoldRateUsed(purity: $purity, ratePaise: $ratePaise, rateDisplay: $rateDisplay, updatedAt: $updatedAt, isStale: $isStale, staleAfterSeconds: $staleAfterSeconds)';
}


}

/// @nodoc
abstract mixin class _$GoldRateUsedCopyWith<$Res> implements $GoldRateUsedCopyWith<$Res> {
  factory _$GoldRateUsedCopyWith(_GoldRateUsed value, $Res Function(_GoldRateUsed) _then) = __$GoldRateUsedCopyWithImpl;
@override @useResult
$Res call({
 String purity,@JsonKey(name: 'rate_paise') int ratePaise,@JsonKey(name: 'rate_display') String rateDisplay,@JsonKey(name: 'updated_at') String updatedAt,@JsonKey(name: 'is_stale') bool? isStale,@JsonKey(name: 'stale_after_seconds') int? staleAfterSeconds
});




}
/// @nodoc
class __$GoldRateUsedCopyWithImpl<$Res>
    implements _$GoldRateUsedCopyWith<$Res> {
  __$GoldRateUsedCopyWithImpl(this._self, this._then);

  final _GoldRateUsed _self;
  final $Res Function(_GoldRateUsed) _then;

/// Create a copy of GoldRateUsed
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? purity = null,Object? ratePaise = null,Object? rateDisplay = null,Object? updatedAt = null,Object? isStale = freezed,Object? staleAfterSeconds = freezed,}) {
  return _then(_GoldRateUsed(
purity: null == purity ? _self.purity : purity // ignore: cast_nullable_to_non_nullable
as String,ratePaise: null == ratePaise ? _self.ratePaise : ratePaise // ignore: cast_nullable_to_non_nullable
as int,rateDisplay: null == rateDisplay ? _self.rateDisplay : rateDisplay // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,isStale: freezed == isStale ? _self.isStale : isStale // ignore: cast_nullable_to_non_nullable
as bool?,staleAfterSeconds: freezed == staleAfterSeconds ? _self.staleAfterSeconds : staleAfterSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$GoldBalance {

@JsonKey(name: 'total_grams') String get totalGrams;@JsonKey(name: 'total_grams_display') String get totalGramsDisplay;@JsonKey(name: 'total_value_paise') int get totalValuePaise;@JsonKey(name: 'total_value_display') String get totalValueDisplay;@JsonKey(name: 'rate_used') GoldRateUsed get rateUsed;
/// Create a copy of GoldBalance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoldBalanceCopyWith<GoldBalance> get copyWith => _$GoldBalanceCopyWithImpl<GoldBalance>(this as GoldBalance, _$identity);

  /// Serializes this GoldBalance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoldBalance&&(identical(other.totalGrams, totalGrams) || other.totalGrams == totalGrams)&&(identical(other.totalGramsDisplay, totalGramsDisplay) || other.totalGramsDisplay == totalGramsDisplay)&&(identical(other.totalValuePaise, totalValuePaise) || other.totalValuePaise == totalValuePaise)&&(identical(other.totalValueDisplay, totalValueDisplay) || other.totalValueDisplay == totalValueDisplay)&&(identical(other.rateUsed, rateUsed) || other.rateUsed == rateUsed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalGrams,totalGramsDisplay,totalValuePaise,totalValueDisplay,rateUsed);

@override
String toString() {
  return 'GoldBalance(totalGrams: $totalGrams, totalGramsDisplay: $totalGramsDisplay, totalValuePaise: $totalValuePaise, totalValueDisplay: $totalValueDisplay, rateUsed: $rateUsed)';
}


}

/// @nodoc
abstract mixin class $GoldBalanceCopyWith<$Res>  {
  factory $GoldBalanceCopyWith(GoldBalance value, $Res Function(GoldBalance) _then) = _$GoldBalanceCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'total_grams') String totalGrams,@JsonKey(name: 'total_grams_display') String totalGramsDisplay,@JsonKey(name: 'total_value_paise') int totalValuePaise,@JsonKey(name: 'total_value_display') String totalValueDisplay,@JsonKey(name: 'rate_used') GoldRateUsed rateUsed
});


$GoldRateUsedCopyWith<$Res> get rateUsed;

}
/// @nodoc
class _$GoldBalanceCopyWithImpl<$Res>
    implements $GoldBalanceCopyWith<$Res> {
  _$GoldBalanceCopyWithImpl(this._self, this._then);

  final GoldBalance _self;
  final $Res Function(GoldBalance) _then;

/// Create a copy of GoldBalance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalGrams = null,Object? totalGramsDisplay = null,Object? totalValuePaise = null,Object? totalValueDisplay = null,Object? rateUsed = null,}) {
  return _then(_self.copyWith(
totalGrams: null == totalGrams ? _self.totalGrams : totalGrams // ignore: cast_nullable_to_non_nullable
as String,totalGramsDisplay: null == totalGramsDisplay ? _self.totalGramsDisplay : totalGramsDisplay // ignore: cast_nullable_to_non_nullable
as String,totalValuePaise: null == totalValuePaise ? _self.totalValuePaise : totalValuePaise // ignore: cast_nullable_to_non_nullable
as int,totalValueDisplay: null == totalValueDisplay ? _self.totalValueDisplay : totalValueDisplay // ignore: cast_nullable_to_non_nullable
as String,rateUsed: null == rateUsed ? _self.rateUsed : rateUsed // ignore: cast_nullable_to_non_nullable
as GoldRateUsed,
  ));
}
/// Create a copy of GoldBalance
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GoldRateUsedCopyWith<$Res> get rateUsed {
  
  return $GoldRateUsedCopyWith<$Res>(_self.rateUsed, (value) {
    return _then(_self.copyWith(rateUsed: value));
  });
}
}


/// Adds pattern-matching-related methods to [GoldBalance].
extension GoldBalancePatterns on GoldBalance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoldBalance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoldBalance() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoldBalance value)  $default,){
final _that = this;
switch (_that) {
case _GoldBalance():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoldBalance value)?  $default,){
final _that = this;
switch (_that) {
case _GoldBalance() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_grams')  String totalGrams, @JsonKey(name: 'total_grams_display')  String totalGramsDisplay, @JsonKey(name: 'total_value_paise')  int totalValuePaise, @JsonKey(name: 'total_value_display')  String totalValueDisplay, @JsonKey(name: 'rate_used')  GoldRateUsed rateUsed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoldBalance() when $default != null:
return $default(_that.totalGrams,_that.totalGramsDisplay,_that.totalValuePaise,_that.totalValueDisplay,_that.rateUsed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_grams')  String totalGrams, @JsonKey(name: 'total_grams_display')  String totalGramsDisplay, @JsonKey(name: 'total_value_paise')  int totalValuePaise, @JsonKey(name: 'total_value_display')  String totalValueDisplay, @JsonKey(name: 'rate_used')  GoldRateUsed rateUsed)  $default,) {final _that = this;
switch (_that) {
case _GoldBalance():
return $default(_that.totalGrams,_that.totalGramsDisplay,_that.totalValuePaise,_that.totalValueDisplay,_that.rateUsed);case _:
  throw StateError('Unexpected subclass');

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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'total_grams')  String totalGrams, @JsonKey(name: 'total_grams_display')  String totalGramsDisplay, @JsonKey(name: 'total_value_paise')  int totalValuePaise, @JsonKey(name: 'total_value_display')  String totalValueDisplay, @JsonKey(name: 'rate_used')  GoldRateUsed rateUsed)?  $default,) {final _that = this;
switch (_that) {
case _GoldBalance() when $default != null:
return $default(_that.totalGrams,_that.totalGramsDisplay,_that.totalValuePaise,_that.totalValueDisplay,_that.rateUsed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoldBalance implements GoldBalance {
  const _GoldBalance({@JsonKey(name: 'total_grams') required this.totalGrams, @JsonKey(name: 'total_grams_display') required this.totalGramsDisplay, @JsonKey(name: 'total_value_paise') required this.totalValuePaise, @JsonKey(name: 'total_value_display') required this.totalValueDisplay, @JsonKey(name: 'rate_used') required this.rateUsed});
  factory _GoldBalance.fromJson(Map<String, dynamic> json) => _$GoldBalanceFromJson(json);

@override@JsonKey(name: 'total_grams') final  String totalGrams;
@override@JsonKey(name: 'total_grams_display') final  String totalGramsDisplay;
@override@JsonKey(name: 'total_value_paise') final  int totalValuePaise;
@override@JsonKey(name: 'total_value_display') final  String totalValueDisplay;
@override@JsonKey(name: 'rate_used') final  GoldRateUsed rateUsed;

/// Create a copy of GoldBalance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoldBalanceCopyWith<_GoldBalance> get copyWith => __$GoldBalanceCopyWithImpl<_GoldBalance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoldBalanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoldBalance&&(identical(other.totalGrams, totalGrams) || other.totalGrams == totalGrams)&&(identical(other.totalGramsDisplay, totalGramsDisplay) || other.totalGramsDisplay == totalGramsDisplay)&&(identical(other.totalValuePaise, totalValuePaise) || other.totalValuePaise == totalValuePaise)&&(identical(other.totalValueDisplay, totalValueDisplay) || other.totalValueDisplay == totalValueDisplay)&&(identical(other.rateUsed, rateUsed) || other.rateUsed == rateUsed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalGrams,totalGramsDisplay,totalValuePaise,totalValueDisplay,rateUsed);

@override
String toString() {
  return 'GoldBalance(totalGrams: $totalGrams, totalGramsDisplay: $totalGramsDisplay, totalValuePaise: $totalValuePaise, totalValueDisplay: $totalValueDisplay, rateUsed: $rateUsed)';
}


}

/// @nodoc
abstract mixin class _$GoldBalanceCopyWith<$Res> implements $GoldBalanceCopyWith<$Res> {
  factory _$GoldBalanceCopyWith(_GoldBalance value, $Res Function(_GoldBalance) _then) = __$GoldBalanceCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'total_grams') String totalGrams,@JsonKey(name: 'total_grams_display') String totalGramsDisplay,@JsonKey(name: 'total_value_paise') int totalValuePaise,@JsonKey(name: 'total_value_display') String totalValueDisplay,@JsonKey(name: 'rate_used') GoldRateUsed rateUsed
});


@override $GoldRateUsedCopyWith<$Res> get rateUsed;

}
/// @nodoc
class __$GoldBalanceCopyWithImpl<$Res>
    implements _$GoldBalanceCopyWith<$Res> {
  __$GoldBalanceCopyWithImpl(this._self, this._then);

  final _GoldBalance _self;
  final $Res Function(_GoldBalance) _then;

/// Create a copy of GoldBalance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalGrams = null,Object? totalGramsDisplay = null,Object? totalValuePaise = null,Object? totalValueDisplay = null,Object? rateUsed = null,}) {
  return _then(_GoldBalance(
totalGrams: null == totalGrams ? _self.totalGrams : totalGrams // ignore: cast_nullable_to_non_nullable
as String,totalGramsDisplay: null == totalGramsDisplay ? _self.totalGramsDisplay : totalGramsDisplay // ignore: cast_nullable_to_non_nullable
as String,totalValuePaise: null == totalValuePaise ? _self.totalValuePaise : totalValuePaise // ignore: cast_nullable_to_non_nullable
as int,totalValueDisplay: null == totalValueDisplay ? _self.totalValueDisplay : totalValueDisplay // ignore: cast_nullable_to_non_nullable
as String,rateUsed: null == rateUsed ? _self.rateUsed : rateUsed // ignore: cast_nullable_to_non_nullable
as GoldRateUsed,
  ));
}

/// Create a copy of GoldBalance
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GoldRateUsedCopyWith<$Res> get rateUsed {
  
  return $GoldRateUsedCopyWith<$Res>(_self.rateUsed, (value) {
    return _then(_self.copyWith(rateUsed: value));
  });
}
}


/// @nodoc
mixin _$GoldLedgerEntry {

 String get id;@JsonKey(name: 'entry_type') String get entryType;@JsonKey(name: 'grams_delta') String get gramsDelta;@JsonKey(name: 'amount_paise') int? get amountPaise;@JsonKey(name: 'gold_rate_per_gram_paise') int get goldRatePerGramPaise;@JsonKey(name: 'source_type') String get sourceType;@JsonKey(name: 'source_id') String get sourceId;@JsonKey(name: 'posted_at') String get postedAt;
/// Create a copy of GoldLedgerEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoldLedgerEntryCopyWith<GoldLedgerEntry> get copyWith => _$GoldLedgerEntryCopyWithImpl<GoldLedgerEntry>(this as GoldLedgerEntry, _$identity);

  /// Serializes this GoldLedgerEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoldLedgerEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.entryType, entryType) || other.entryType == entryType)&&(identical(other.gramsDelta, gramsDelta) || other.gramsDelta == gramsDelta)&&(identical(other.amountPaise, amountPaise) || other.amountPaise == amountPaise)&&(identical(other.goldRatePerGramPaise, goldRatePerGramPaise) || other.goldRatePerGramPaise == goldRatePerGramPaise)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.postedAt, postedAt) || other.postedAt == postedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,entryType,gramsDelta,amountPaise,goldRatePerGramPaise,sourceType,sourceId,postedAt);

@override
String toString() {
  return 'GoldLedgerEntry(id: $id, entryType: $entryType, gramsDelta: $gramsDelta, amountPaise: $amountPaise, goldRatePerGramPaise: $goldRatePerGramPaise, sourceType: $sourceType, sourceId: $sourceId, postedAt: $postedAt)';
}


}

/// @nodoc
abstract mixin class $GoldLedgerEntryCopyWith<$Res>  {
  factory $GoldLedgerEntryCopyWith(GoldLedgerEntry value, $Res Function(GoldLedgerEntry) _then) = _$GoldLedgerEntryCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'entry_type') String entryType,@JsonKey(name: 'grams_delta') String gramsDelta,@JsonKey(name: 'amount_paise') int? amountPaise,@JsonKey(name: 'gold_rate_per_gram_paise') int goldRatePerGramPaise,@JsonKey(name: 'source_type') String sourceType,@JsonKey(name: 'source_id') String sourceId,@JsonKey(name: 'posted_at') String postedAt
});




}
/// @nodoc
class _$GoldLedgerEntryCopyWithImpl<$Res>
    implements $GoldLedgerEntryCopyWith<$Res> {
  _$GoldLedgerEntryCopyWithImpl(this._self, this._then);

  final GoldLedgerEntry _self;
  final $Res Function(GoldLedgerEntry) _then;

/// Create a copy of GoldLedgerEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? entryType = null,Object? gramsDelta = null,Object? amountPaise = freezed,Object? goldRatePerGramPaise = null,Object? sourceType = null,Object? sourceId = null,Object? postedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,entryType: null == entryType ? _self.entryType : entryType // ignore: cast_nullable_to_non_nullable
as String,gramsDelta: null == gramsDelta ? _self.gramsDelta : gramsDelta // ignore: cast_nullable_to_non_nullable
as String,amountPaise: freezed == amountPaise ? _self.amountPaise : amountPaise // ignore: cast_nullable_to_non_nullable
as int?,goldRatePerGramPaise: null == goldRatePerGramPaise ? _self.goldRatePerGramPaise : goldRatePerGramPaise // ignore: cast_nullable_to_non_nullable
as int,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as String,sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,postedAt: null == postedAt ? _self.postedAt : postedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GoldLedgerEntry].
extension GoldLedgerEntryPatterns on GoldLedgerEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoldLedgerEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoldLedgerEntry() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoldLedgerEntry value)  $default,){
final _that = this;
switch (_that) {
case _GoldLedgerEntry():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoldLedgerEntry value)?  $default,){
final _that = this;
switch (_that) {
case _GoldLedgerEntry() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'entry_type')  String entryType, @JsonKey(name: 'grams_delta')  String gramsDelta, @JsonKey(name: 'amount_paise')  int? amountPaise, @JsonKey(name: 'gold_rate_per_gram_paise')  int goldRatePerGramPaise, @JsonKey(name: 'source_type')  String sourceType, @JsonKey(name: 'source_id')  String sourceId, @JsonKey(name: 'posted_at')  String postedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoldLedgerEntry() when $default != null:
return $default(_that.id,_that.entryType,_that.gramsDelta,_that.amountPaise,_that.goldRatePerGramPaise,_that.sourceType,_that.sourceId,_that.postedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'entry_type')  String entryType, @JsonKey(name: 'grams_delta')  String gramsDelta, @JsonKey(name: 'amount_paise')  int? amountPaise, @JsonKey(name: 'gold_rate_per_gram_paise')  int goldRatePerGramPaise, @JsonKey(name: 'source_type')  String sourceType, @JsonKey(name: 'source_id')  String sourceId, @JsonKey(name: 'posted_at')  String postedAt)  $default,) {final _that = this;
switch (_that) {
case _GoldLedgerEntry():
return $default(_that.id,_that.entryType,_that.gramsDelta,_that.amountPaise,_that.goldRatePerGramPaise,_that.sourceType,_that.sourceId,_that.postedAt);case _:
  throw StateError('Unexpected subclass');

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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'entry_type')  String entryType, @JsonKey(name: 'grams_delta')  String gramsDelta, @JsonKey(name: 'amount_paise')  int? amountPaise, @JsonKey(name: 'gold_rate_per_gram_paise')  int goldRatePerGramPaise, @JsonKey(name: 'source_type')  String sourceType, @JsonKey(name: 'source_id')  String sourceId, @JsonKey(name: 'posted_at')  String postedAt)?  $default,) {final _that = this;
switch (_that) {
case _GoldLedgerEntry() when $default != null:
return $default(_that.id,_that.entryType,_that.gramsDelta,_that.amountPaise,_that.goldRatePerGramPaise,_that.sourceType,_that.sourceId,_that.postedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoldLedgerEntry implements GoldLedgerEntry {
  const _GoldLedgerEntry({required this.id, @JsonKey(name: 'entry_type') required this.entryType, @JsonKey(name: 'grams_delta') required this.gramsDelta, @JsonKey(name: 'amount_paise') this.amountPaise, @JsonKey(name: 'gold_rate_per_gram_paise') required this.goldRatePerGramPaise, @JsonKey(name: 'source_type') required this.sourceType, @JsonKey(name: 'source_id') required this.sourceId, @JsonKey(name: 'posted_at') required this.postedAt});
  factory _GoldLedgerEntry.fromJson(Map<String, dynamic> json) => _$GoldLedgerEntryFromJson(json);

@override final  String id;
@override@JsonKey(name: 'entry_type') final  String entryType;
@override@JsonKey(name: 'grams_delta') final  String gramsDelta;
@override@JsonKey(name: 'amount_paise') final  int? amountPaise;
@override@JsonKey(name: 'gold_rate_per_gram_paise') final  int goldRatePerGramPaise;
@override@JsonKey(name: 'source_type') final  String sourceType;
@override@JsonKey(name: 'source_id') final  String sourceId;
@override@JsonKey(name: 'posted_at') final  String postedAt;

/// Create a copy of GoldLedgerEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoldLedgerEntryCopyWith<_GoldLedgerEntry> get copyWith => __$GoldLedgerEntryCopyWithImpl<_GoldLedgerEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoldLedgerEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoldLedgerEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.entryType, entryType) || other.entryType == entryType)&&(identical(other.gramsDelta, gramsDelta) || other.gramsDelta == gramsDelta)&&(identical(other.amountPaise, amountPaise) || other.amountPaise == amountPaise)&&(identical(other.goldRatePerGramPaise, goldRatePerGramPaise) || other.goldRatePerGramPaise == goldRatePerGramPaise)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.postedAt, postedAt) || other.postedAt == postedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,entryType,gramsDelta,amountPaise,goldRatePerGramPaise,sourceType,sourceId,postedAt);

@override
String toString() {
  return 'GoldLedgerEntry(id: $id, entryType: $entryType, gramsDelta: $gramsDelta, amountPaise: $amountPaise, goldRatePerGramPaise: $goldRatePerGramPaise, sourceType: $sourceType, sourceId: $sourceId, postedAt: $postedAt)';
}


}

/// @nodoc
abstract mixin class _$GoldLedgerEntryCopyWith<$Res> implements $GoldLedgerEntryCopyWith<$Res> {
  factory _$GoldLedgerEntryCopyWith(_GoldLedgerEntry value, $Res Function(_GoldLedgerEntry) _then) = __$GoldLedgerEntryCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'entry_type') String entryType,@JsonKey(name: 'grams_delta') String gramsDelta,@JsonKey(name: 'amount_paise') int? amountPaise,@JsonKey(name: 'gold_rate_per_gram_paise') int goldRatePerGramPaise,@JsonKey(name: 'source_type') String sourceType,@JsonKey(name: 'source_id') String sourceId,@JsonKey(name: 'posted_at') String postedAt
});




}
/// @nodoc
class __$GoldLedgerEntryCopyWithImpl<$Res>
    implements _$GoldLedgerEntryCopyWith<$Res> {
  __$GoldLedgerEntryCopyWithImpl(this._self, this._then);

  final _GoldLedgerEntry _self;
  final $Res Function(_GoldLedgerEntry) _then;

/// Create a copy of GoldLedgerEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? entryType = null,Object? gramsDelta = null,Object? amountPaise = freezed,Object? goldRatePerGramPaise = null,Object? sourceType = null,Object? sourceId = null,Object? postedAt = null,}) {
  return _then(_GoldLedgerEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,entryType: null == entryType ? _self.entryType : entryType // ignore: cast_nullable_to_non_nullable
as String,gramsDelta: null == gramsDelta ? _self.gramsDelta : gramsDelta // ignore: cast_nullable_to_non_nullable
as String,amountPaise: freezed == amountPaise ? _self.amountPaise : amountPaise // ignore: cast_nullable_to_non_nullable
as int?,goldRatePerGramPaise: null == goldRatePerGramPaise ? _self.goldRatePerGramPaise : goldRatePerGramPaise // ignore: cast_nullable_to_non_nullable
as int,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as String,sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,postedAt: null == postedAt ? _self.postedAt : postedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$GoldLedgerResponse {

 List<GoldLedgerEntry> get data;@JsonKey(name: 'next_cursor') String? get nextCursor;@JsonKey(name: 'has_more') bool get hasMore;
/// Create a copy of GoldLedgerResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoldLedgerResponseCopyWith<GoldLedgerResponse> get copyWith => _$GoldLedgerResponseCopyWithImpl<GoldLedgerResponse>(this as GoldLedgerResponse, _$identity);

  /// Serializes this GoldLedgerResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoldLedgerResponse&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data),nextCursor,hasMore);

@override
String toString() {
  return 'GoldLedgerResponse(data: $data, nextCursor: $nextCursor, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class $GoldLedgerResponseCopyWith<$Res>  {
  factory $GoldLedgerResponseCopyWith(GoldLedgerResponse value, $Res Function(GoldLedgerResponse) _then) = _$GoldLedgerResponseCopyWithImpl;
@useResult
$Res call({
 List<GoldLedgerEntry> data,@JsonKey(name: 'next_cursor') String? nextCursor,@JsonKey(name: 'has_more') bool hasMore
});




}
/// @nodoc
class _$GoldLedgerResponseCopyWithImpl<$Res>
    implements $GoldLedgerResponseCopyWith<$Res> {
  _$GoldLedgerResponseCopyWithImpl(this._self, this._then);

  final GoldLedgerResponse _self;
  final $Res Function(GoldLedgerResponse) _then;

/// Create a copy of GoldLedgerResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? nextCursor = freezed,Object? hasMore = null,}) {
  return _then(_self.copyWith(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as List<GoldLedgerEntry>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GoldLedgerResponse].
extension GoldLedgerResponsePatterns on GoldLedgerResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoldLedgerResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoldLedgerResponse() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoldLedgerResponse value)  $default,){
final _that = this;
switch (_that) {
case _GoldLedgerResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoldLedgerResponse value)?  $default,){
final _that = this;
switch (_that) {
case _GoldLedgerResponse() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<GoldLedgerEntry> data, @JsonKey(name: 'next_cursor')  String? nextCursor, @JsonKey(name: 'has_more')  bool hasMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoldLedgerResponse() when $default != null:
return $default(_that.data,_that.nextCursor,_that.hasMore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<GoldLedgerEntry> data, @JsonKey(name: 'next_cursor')  String? nextCursor, @JsonKey(name: 'has_more')  bool hasMore)  $default,) {final _that = this;
switch (_that) {
case _GoldLedgerResponse():
return $default(_that.data,_that.nextCursor,_that.hasMore);case _:
  throw StateError('Unexpected subclass');

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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<GoldLedgerEntry> data, @JsonKey(name: 'next_cursor')  String? nextCursor, @JsonKey(name: 'has_more')  bool hasMore)?  $default,) {final _that = this;
switch (_that) {
case _GoldLedgerResponse() when $default != null:
return $default(_that.data,_that.nextCursor,_that.hasMore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoldLedgerResponse implements GoldLedgerResponse {
  const _GoldLedgerResponse({required final  List<GoldLedgerEntry> data, @JsonKey(name: 'next_cursor') this.nextCursor, @JsonKey(name: 'has_more') required this.hasMore}): _data = data;
  factory _GoldLedgerResponse.fromJson(Map<String, dynamic> json) => _$GoldLedgerResponseFromJson(json);

 final  List<GoldLedgerEntry> _data;
@override List<GoldLedgerEntry> get data {
  if (_data is EqualUnmodifiableListView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_data);
}

@override@JsonKey(name: 'next_cursor') final  String? nextCursor;
@override@JsonKey(name: 'has_more') final  bool hasMore;

/// Create a copy of GoldLedgerResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoldLedgerResponseCopyWith<_GoldLedgerResponse> get copyWith => __$GoldLedgerResponseCopyWithImpl<_GoldLedgerResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoldLedgerResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoldLedgerResponse&&const DeepCollectionEquality().equals(other._data, _data)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_data),nextCursor,hasMore);

@override
String toString() {
  return 'GoldLedgerResponse(data: $data, nextCursor: $nextCursor, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class _$GoldLedgerResponseCopyWith<$Res> implements $GoldLedgerResponseCopyWith<$Res> {
  factory _$GoldLedgerResponseCopyWith(_GoldLedgerResponse value, $Res Function(_GoldLedgerResponse) _then) = __$GoldLedgerResponseCopyWithImpl;
@override @useResult
$Res call({
 List<GoldLedgerEntry> data,@JsonKey(name: 'next_cursor') String? nextCursor,@JsonKey(name: 'has_more') bool hasMore
});




}
/// @nodoc
class __$GoldLedgerResponseCopyWithImpl<$Res>
    implements _$GoldLedgerResponseCopyWith<$Res> {
  __$GoldLedgerResponseCopyWithImpl(this._self, this._then);

  final _GoldLedgerResponse _self;
  final $Res Function(_GoldLedgerResponse) _then;

/// Create a copy of GoldLedgerResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? nextCursor = freezed,Object? hasMore = null,}) {
  return _then(_GoldLedgerResponse(
data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as List<GoldLedgerEntry>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$RedeemableProductsResponse {

 List<dynamic> get data;@JsonKey(name: 'next_cursor') String? get nextCursor;@JsonKey(name: 'has_more') bool get hasMore;
/// Create a copy of RedeemableProductsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RedeemableProductsResponseCopyWith<RedeemableProductsResponse> get copyWith => _$RedeemableProductsResponseCopyWithImpl<RedeemableProductsResponse>(this as RedeemableProductsResponse, _$identity);

  /// Serializes this RedeemableProductsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RedeemableProductsResponse&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data),nextCursor,hasMore);

@override
String toString() {
  return 'RedeemableProductsResponse(data: $data, nextCursor: $nextCursor, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class $RedeemableProductsResponseCopyWith<$Res>  {
  factory $RedeemableProductsResponseCopyWith(RedeemableProductsResponse value, $Res Function(RedeemableProductsResponse) _then) = _$RedeemableProductsResponseCopyWithImpl;
@useResult
$Res call({
 List<dynamic> data,@JsonKey(name: 'next_cursor') String? nextCursor,@JsonKey(name: 'has_more') bool hasMore
});




}
/// @nodoc
class _$RedeemableProductsResponseCopyWithImpl<$Res>
    implements $RedeemableProductsResponseCopyWith<$Res> {
  _$RedeemableProductsResponseCopyWithImpl(this._self, this._then);

  final RedeemableProductsResponse _self;
  final $Res Function(RedeemableProductsResponse) _then;

/// Create a copy of RedeemableProductsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? nextCursor = freezed,Object? hasMore = null,}) {
  return _then(_self.copyWith(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as List<dynamic>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RedeemableProductsResponse].
extension RedeemableProductsResponsePatterns on RedeemableProductsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RedeemableProductsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RedeemableProductsResponse() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RedeemableProductsResponse value)  $default,){
final _that = this;
switch (_that) {
case _RedeemableProductsResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RedeemableProductsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _RedeemableProductsResponse() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<dynamic> data, @JsonKey(name: 'next_cursor')  String? nextCursor, @JsonKey(name: 'has_more')  bool hasMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RedeemableProductsResponse() when $default != null:
return $default(_that.data,_that.nextCursor,_that.hasMore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<dynamic> data, @JsonKey(name: 'next_cursor')  String? nextCursor, @JsonKey(name: 'has_more')  bool hasMore)  $default,) {final _that = this;
switch (_that) {
case _RedeemableProductsResponse():
return $default(_that.data,_that.nextCursor,_that.hasMore);case _:
  throw StateError('Unexpected subclass');

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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<dynamic> data, @JsonKey(name: 'next_cursor')  String? nextCursor, @JsonKey(name: 'has_more')  bool hasMore)?  $default,) {final _that = this;
switch (_that) {
case _RedeemableProductsResponse() when $default != null:
return $default(_that.data,_that.nextCursor,_that.hasMore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RedeemableProductsResponse implements RedeemableProductsResponse {
  const _RedeemableProductsResponse({required final  List<dynamic> data, @JsonKey(name: 'next_cursor') this.nextCursor, @JsonKey(name: 'has_more') required this.hasMore}): _data = data;
  factory _RedeemableProductsResponse.fromJson(Map<String, dynamic> json) => _$RedeemableProductsResponseFromJson(json);

 final  List<dynamic> _data;
@override List<dynamic> get data {
  if (_data is EqualUnmodifiableListView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_data);
}

@override@JsonKey(name: 'next_cursor') final  String? nextCursor;
@override@JsonKey(name: 'has_more') final  bool hasMore;

/// Create a copy of RedeemableProductsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RedeemableProductsResponseCopyWith<_RedeemableProductsResponse> get copyWith => __$RedeemableProductsResponseCopyWithImpl<_RedeemableProductsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RedeemableProductsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RedeemableProductsResponse&&const DeepCollectionEquality().equals(other._data, _data)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_data),nextCursor,hasMore);

@override
String toString() {
  return 'RedeemableProductsResponse(data: $data, nextCursor: $nextCursor, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class _$RedeemableProductsResponseCopyWith<$Res> implements $RedeemableProductsResponseCopyWith<$Res> {
  factory _$RedeemableProductsResponseCopyWith(_RedeemableProductsResponse value, $Res Function(_RedeemableProductsResponse) _then) = __$RedeemableProductsResponseCopyWithImpl;
@override @useResult
$Res call({
 List<dynamic> data,@JsonKey(name: 'next_cursor') String? nextCursor,@JsonKey(name: 'has_more') bool hasMore
});




}
/// @nodoc
class __$RedeemableProductsResponseCopyWithImpl<$Res>
    implements _$RedeemableProductsResponseCopyWith<$Res> {
  __$RedeemableProductsResponseCopyWithImpl(this._self, this._then);

  final _RedeemableProductsResponse _self;
  final $Res Function(_RedeemableProductsResponse) _then;

/// Create a copy of RedeemableProductsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? nextCursor = freezed,Object? hasMore = null,}) {
  return _then(_RedeemableProductsResponse(
data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as List<dynamic>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PendingContributionsResponse {

 List<PendingContribution> get pending;
/// Create a copy of PendingContributionsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingContributionsResponseCopyWith<PendingContributionsResponse> get copyWith => _$PendingContributionsResponseCopyWithImpl<PendingContributionsResponse>(this as PendingContributionsResponse, _$identity);

  /// Serializes this PendingContributionsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingContributionsResponse&&const DeepCollectionEquality().equals(other.pending, pending));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(pending));

@override
String toString() {
  return 'PendingContributionsResponse(pending: $pending)';
}


}

/// @nodoc
abstract mixin class $PendingContributionsResponseCopyWith<$Res>  {
  factory $PendingContributionsResponseCopyWith(PendingContributionsResponse value, $Res Function(PendingContributionsResponse) _then) = _$PendingContributionsResponseCopyWithImpl;
@useResult
$Res call({
 List<PendingContribution> pending
});




}
/// @nodoc
class _$PendingContributionsResponseCopyWithImpl<$Res>
    implements $PendingContributionsResponseCopyWith<$Res> {
  _$PendingContributionsResponseCopyWithImpl(this._self, this._then);

  final PendingContributionsResponse _self;
  final $Res Function(PendingContributionsResponse) _then;

/// Create a copy of PendingContributionsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pending = null,}) {
  return _then(_self.copyWith(
pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as List<PendingContribution>,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingContributionsResponse].
extension PendingContributionsResponsePatterns on PendingContributionsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingContributionsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingContributionsResponse() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingContributionsResponse value)  $default,){
final _that = this;
switch (_that) {
case _PendingContributionsResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingContributionsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PendingContributionsResponse() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PendingContribution> pending)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingContributionsResponse() when $default != null:
return $default(_that.pending);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PendingContribution> pending)  $default,) {final _that = this;
switch (_that) {
case _PendingContributionsResponse():
return $default(_that.pending);case _:
  throw StateError('Unexpected subclass');

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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PendingContribution> pending)?  $default,) {final _that = this;
switch (_that) {
case _PendingContributionsResponse() when $default != null:
return $default(_that.pending);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PendingContributionsResponse implements PendingContributionsResponse {
  const _PendingContributionsResponse({required final  List<PendingContribution> pending}): _pending = pending;
  factory _PendingContributionsResponse.fromJson(Map<String, dynamic> json) => _$PendingContributionsResponseFromJson(json);

 final  List<PendingContribution> _pending;
@override List<PendingContribution> get pending {
  if (_pending is EqualUnmodifiableListView) return _pending;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pending);
}


/// Create a copy of PendingContributionsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingContributionsResponseCopyWith<_PendingContributionsResponse> get copyWith => __$PendingContributionsResponseCopyWithImpl<_PendingContributionsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PendingContributionsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingContributionsResponse&&const DeepCollectionEquality().equals(other._pending, _pending));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_pending));

@override
String toString() {
  return 'PendingContributionsResponse(pending: $pending)';
}


}

/// @nodoc
abstract mixin class _$PendingContributionsResponseCopyWith<$Res> implements $PendingContributionsResponseCopyWith<$Res> {
  factory _$PendingContributionsResponseCopyWith(_PendingContributionsResponse value, $Res Function(_PendingContributionsResponse) _then) = __$PendingContributionsResponseCopyWithImpl;
@override @useResult
$Res call({
 List<PendingContribution> pending
});




}
/// @nodoc
class __$PendingContributionsResponseCopyWithImpl<$Res>
    implements _$PendingContributionsResponseCopyWith<$Res> {
  __$PendingContributionsResponseCopyWithImpl(this._self, this._then);

  final _PendingContributionsResponse _self;
  final $Res Function(_PendingContributionsResponse) _then;

/// Create a copy of PendingContributionsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pending = null,}) {
  return _then(_PendingContributionsResponse(
pending: null == pending ? _self._pending : pending // ignore: cast_nullable_to_non_nullable
as List<PendingContribution>,
  ));
}


}


/// @nodoc
mixin _$PendingContribution {

 String get id;@JsonKey(name: 'goal_id') String get goalId; String get status;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of PendingContribution
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingContributionCopyWith<PendingContribution> get copyWith => _$PendingContributionCopyWithImpl<PendingContribution>(this as PendingContribution, _$identity);

  /// Serializes this PendingContribution to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingContribution&&(identical(other.id, id) || other.id == id)&&(identical(other.goalId, goalId) || other.goalId == goalId)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,goalId,status,createdAt);

@override
String toString() {
  return 'PendingContribution(id: $id, goalId: $goalId, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PendingContributionCopyWith<$Res>  {
  factory $PendingContributionCopyWith(PendingContribution value, $Res Function(PendingContribution) _then) = _$PendingContributionCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'goal_id') String goalId, String status,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class _$PendingContributionCopyWithImpl<$Res>
    implements $PendingContributionCopyWith<$Res> {
  _$PendingContributionCopyWithImpl(this._self, this._then);

  final PendingContribution _self;
  final $Res Function(PendingContribution) _then;

/// Create a copy of PendingContribution
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? goalId = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,goalId: null == goalId ? _self.goalId : goalId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingContribution].
extension PendingContributionPatterns on PendingContribution {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingContribution value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingContribution() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingContribution value)  $default,){
final _that = this;
switch (_that) {
case _PendingContribution():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingContribution value)?  $default,){
final _that = this;
switch (_that) {
case _PendingContribution() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'goal_id')  String goalId,  String status, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingContribution() when $default != null:
return $default(_that.id,_that.goalId,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'goal_id')  String goalId,  String status, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _PendingContribution():
return $default(_that.id,_that.goalId,_that.status,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'goal_id')  String goalId,  String status, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PendingContribution() when $default != null:
return $default(_that.id,_that.goalId,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PendingContribution implements PendingContribution {
  const _PendingContribution({required this.id, @JsonKey(name: 'goal_id') required this.goalId, required this.status, @JsonKey(name: 'created_at') required this.createdAt});
  factory _PendingContribution.fromJson(Map<String, dynamic> json) => _$PendingContributionFromJson(json);

@override final  String id;
@override@JsonKey(name: 'goal_id') final  String goalId;
@override final  String status;
@override@JsonKey(name: 'created_at') final  String createdAt;

/// Create a copy of PendingContribution
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingContributionCopyWith<_PendingContribution> get copyWith => __$PendingContributionCopyWithImpl<_PendingContribution>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PendingContributionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingContribution&&(identical(other.id, id) || other.id == id)&&(identical(other.goalId, goalId) || other.goalId == goalId)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,goalId,status,createdAt);

@override
String toString() {
  return 'PendingContribution(id: $id, goalId: $goalId, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PendingContributionCopyWith<$Res> implements $PendingContributionCopyWith<$Res> {
  factory _$PendingContributionCopyWith(_PendingContribution value, $Res Function(_PendingContribution) _then) = __$PendingContributionCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'goal_id') String goalId, String status,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class __$PendingContributionCopyWithImpl<$Res>
    implements _$PendingContributionCopyWith<$Res> {
  __$PendingContributionCopyWithImpl(this._self, this._then);

  final _PendingContribution _self;
  final $Res Function(_PendingContribution) _then;

/// Create a copy of PendingContribution
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? goalId = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_PendingContribution(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,goalId: null == goalId ? _self.goalId : goalId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
