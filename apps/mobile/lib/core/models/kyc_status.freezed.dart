// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kyc_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$KycStatusResponse {

@JsonKey(name: 'kyc_status') String get kycStatus;@JsonKey(name: 'aadhaar_verified') bool get aadhaarVerified;@JsonKey(name: 'pan_verified') bool get panVerified;@JsonKey(name: 'bank_verified') bool get bankVerified;@JsonKey(name: 'selfie_verified') bool get selfieVerified;@JsonKey(name: 'submitted_at') String? get submittedAt;@JsonKey(name: 'rejection_reason') String? get rejectionReason;@JsonKey(name: 'resubmission_allowed_at') String? get resubmissionAllowedAt;
/// Create a copy of KycStatusResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KycStatusResponseCopyWith<KycStatusResponse> get copyWith => _$KycStatusResponseCopyWithImpl<KycStatusResponse>(this as KycStatusResponse, _$identity);

  /// Serializes this KycStatusResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KycStatusResponse&&(identical(other.kycStatus, kycStatus) || other.kycStatus == kycStatus)&&(identical(other.aadhaarVerified, aadhaarVerified) || other.aadhaarVerified == aadhaarVerified)&&(identical(other.panVerified, panVerified) || other.panVerified == panVerified)&&(identical(other.bankVerified, bankVerified) || other.bankVerified == bankVerified)&&(identical(other.selfieVerified, selfieVerified) || other.selfieVerified == selfieVerified)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.resubmissionAllowedAt, resubmissionAllowedAt) || other.resubmissionAllowedAt == resubmissionAllowedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kycStatus,aadhaarVerified,panVerified,bankVerified,selfieVerified,submittedAt,rejectionReason,resubmissionAllowedAt);

@override
String toString() {
  return 'KycStatusResponse(kycStatus: $kycStatus, aadhaarVerified: $aadhaarVerified, panVerified: $panVerified, bankVerified: $bankVerified, selfieVerified: $selfieVerified, submittedAt: $submittedAt, rejectionReason: $rejectionReason, resubmissionAllowedAt: $resubmissionAllowedAt)';
}


}

/// @nodoc
abstract mixin class $KycStatusResponseCopyWith<$Res>  {
  factory $KycStatusResponseCopyWith(KycStatusResponse value, $Res Function(KycStatusResponse) _then) = _$KycStatusResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'kyc_status') String kycStatus,@JsonKey(name: 'aadhaar_verified') bool aadhaarVerified,@JsonKey(name: 'pan_verified') bool panVerified,@JsonKey(name: 'bank_verified') bool bankVerified,@JsonKey(name: 'selfie_verified') bool selfieVerified,@JsonKey(name: 'submitted_at') String? submittedAt,@JsonKey(name: 'rejection_reason') String? rejectionReason,@JsonKey(name: 'resubmission_allowed_at') String? resubmissionAllowedAt
});




}
/// @nodoc
class _$KycStatusResponseCopyWithImpl<$Res>
    implements $KycStatusResponseCopyWith<$Res> {
  _$KycStatusResponseCopyWithImpl(this._self, this._then);

  final KycStatusResponse _self;
  final $Res Function(KycStatusResponse) _then;

/// Create a copy of KycStatusResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kycStatus = null,Object? aadhaarVerified = null,Object? panVerified = null,Object? bankVerified = null,Object? selfieVerified = null,Object? submittedAt = freezed,Object? rejectionReason = freezed,Object? resubmissionAllowedAt = freezed,}) {
  return _then(_self.copyWith(
kycStatus: null == kycStatus ? _self.kycStatus : kycStatus // ignore: cast_nullable_to_non_nullable
as String,aadhaarVerified: null == aadhaarVerified ? _self.aadhaarVerified : aadhaarVerified // ignore: cast_nullable_to_non_nullable
as bool,panVerified: null == panVerified ? _self.panVerified : panVerified // ignore: cast_nullable_to_non_nullable
as bool,bankVerified: null == bankVerified ? _self.bankVerified : bankVerified // ignore: cast_nullable_to_non_nullable
as bool,selfieVerified: null == selfieVerified ? _self.selfieVerified : selfieVerified // ignore: cast_nullable_to_non_nullable
as bool,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,resubmissionAllowedAt: freezed == resubmissionAllowedAt ? _self.resubmissionAllowedAt : resubmissionAllowedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [KycStatusResponse].
extension KycStatusResponsePatterns on KycStatusResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KycStatusResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KycStatusResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KycStatusResponse value)  $default,){
final _that = this;
switch (_that) {
case _KycStatusResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KycStatusResponse value)?  $default,){
final _that = this;
switch (_that) {
case _KycStatusResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'kyc_status')  String kycStatus, @JsonKey(name: 'aadhaar_verified')  bool aadhaarVerified, @JsonKey(name: 'pan_verified')  bool panVerified, @JsonKey(name: 'bank_verified')  bool bankVerified, @JsonKey(name: 'selfie_verified')  bool selfieVerified, @JsonKey(name: 'submitted_at')  String? submittedAt, @JsonKey(name: 'rejection_reason')  String? rejectionReason, @JsonKey(name: 'resubmission_allowed_at')  String? resubmissionAllowedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KycStatusResponse() when $default != null:
return $default(_that.kycStatus,_that.aadhaarVerified,_that.panVerified,_that.bankVerified,_that.selfieVerified,_that.submittedAt,_that.rejectionReason,_that.resubmissionAllowedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'kyc_status')  String kycStatus, @JsonKey(name: 'aadhaar_verified')  bool aadhaarVerified, @JsonKey(name: 'pan_verified')  bool panVerified, @JsonKey(name: 'bank_verified')  bool bankVerified, @JsonKey(name: 'selfie_verified')  bool selfieVerified, @JsonKey(name: 'submitted_at')  String? submittedAt, @JsonKey(name: 'rejection_reason')  String? rejectionReason, @JsonKey(name: 'resubmission_allowed_at')  String? resubmissionAllowedAt)  $default,) {final _that = this;
switch (_that) {
case _KycStatusResponse():
return $default(_that.kycStatus,_that.aadhaarVerified,_that.panVerified,_that.bankVerified,_that.selfieVerified,_that.submittedAt,_that.rejectionReason,_that.resubmissionAllowedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'kyc_status')  String kycStatus, @JsonKey(name: 'aadhaar_verified')  bool aadhaarVerified, @JsonKey(name: 'pan_verified')  bool panVerified, @JsonKey(name: 'bank_verified')  bool bankVerified, @JsonKey(name: 'selfie_verified')  bool selfieVerified, @JsonKey(name: 'submitted_at')  String? submittedAt, @JsonKey(name: 'rejection_reason')  String? rejectionReason, @JsonKey(name: 'resubmission_allowed_at')  String? resubmissionAllowedAt)?  $default,) {final _that = this;
switch (_that) {
case _KycStatusResponse() when $default != null:
return $default(_that.kycStatus,_that.aadhaarVerified,_that.panVerified,_that.bankVerified,_that.selfieVerified,_that.submittedAt,_that.rejectionReason,_that.resubmissionAllowedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KycStatusResponse implements KycStatusResponse {
  const _KycStatusResponse({@JsonKey(name: 'kyc_status') required this.kycStatus, @JsonKey(name: 'aadhaar_verified') this.aadhaarVerified = false, @JsonKey(name: 'pan_verified') this.panVerified = false, @JsonKey(name: 'bank_verified') this.bankVerified = false, @JsonKey(name: 'selfie_verified') this.selfieVerified = false, @JsonKey(name: 'submitted_at') this.submittedAt, @JsonKey(name: 'rejection_reason') this.rejectionReason, @JsonKey(name: 'resubmission_allowed_at') this.resubmissionAllowedAt});
  factory _KycStatusResponse.fromJson(Map<String, dynamic> json) => _$KycStatusResponseFromJson(json);

@override@JsonKey(name: 'kyc_status') final  String kycStatus;
@override@JsonKey(name: 'aadhaar_verified') final  bool aadhaarVerified;
@override@JsonKey(name: 'pan_verified') final  bool panVerified;
@override@JsonKey(name: 'bank_verified') final  bool bankVerified;
@override@JsonKey(name: 'selfie_verified') final  bool selfieVerified;
@override@JsonKey(name: 'submitted_at') final  String? submittedAt;
@override@JsonKey(name: 'rejection_reason') final  String? rejectionReason;
@override@JsonKey(name: 'resubmission_allowed_at') final  String? resubmissionAllowedAt;

/// Create a copy of KycStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KycStatusResponseCopyWith<_KycStatusResponse> get copyWith => __$KycStatusResponseCopyWithImpl<_KycStatusResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KycStatusResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KycStatusResponse&&(identical(other.kycStatus, kycStatus) || other.kycStatus == kycStatus)&&(identical(other.aadhaarVerified, aadhaarVerified) || other.aadhaarVerified == aadhaarVerified)&&(identical(other.panVerified, panVerified) || other.panVerified == panVerified)&&(identical(other.bankVerified, bankVerified) || other.bankVerified == bankVerified)&&(identical(other.selfieVerified, selfieVerified) || other.selfieVerified == selfieVerified)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.resubmissionAllowedAt, resubmissionAllowedAt) || other.resubmissionAllowedAt == resubmissionAllowedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kycStatus,aadhaarVerified,panVerified,bankVerified,selfieVerified,submittedAt,rejectionReason,resubmissionAllowedAt);

@override
String toString() {
  return 'KycStatusResponse(kycStatus: $kycStatus, aadhaarVerified: $aadhaarVerified, panVerified: $panVerified, bankVerified: $bankVerified, selfieVerified: $selfieVerified, submittedAt: $submittedAt, rejectionReason: $rejectionReason, resubmissionAllowedAt: $resubmissionAllowedAt)';
}


}

/// @nodoc
abstract mixin class _$KycStatusResponseCopyWith<$Res> implements $KycStatusResponseCopyWith<$Res> {
  factory _$KycStatusResponseCopyWith(_KycStatusResponse value, $Res Function(_KycStatusResponse) _then) = __$KycStatusResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'kyc_status') String kycStatus,@JsonKey(name: 'aadhaar_verified') bool aadhaarVerified,@JsonKey(name: 'pan_verified') bool panVerified,@JsonKey(name: 'bank_verified') bool bankVerified,@JsonKey(name: 'selfie_verified') bool selfieVerified,@JsonKey(name: 'submitted_at') String? submittedAt,@JsonKey(name: 'rejection_reason') String? rejectionReason,@JsonKey(name: 'resubmission_allowed_at') String? resubmissionAllowedAt
});




}
/// @nodoc
class __$KycStatusResponseCopyWithImpl<$Res>
    implements _$KycStatusResponseCopyWith<$Res> {
  __$KycStatusResponseCopyWithImpl(this._self, this._then);

  final _KycStatusResponse _self;
  final $Res Function(_KycStatusResponse) _then;

/// Create a copy of KycStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kycStatus = null,Object? aadhaarVerified = null,Object? panVerified = null,Object? bankVerified = null,Object? selfieVerified = null,Object? submittedAt = freezed,Object? rejectionReason = freezed,Object? resubmissionAllowedAt = freezed,}) {
  return _then(_KycStatusResponse(
kycStatus: null == kycStatus ? _self.kycStatus : kycStatus // ignore: cast_nullable_to_non_nullable
as String,aadhaarVerified: null == aadhaarVerified ? _self.aadhaarVerified : aadhaarVerified // ignore: cast_nullable_to_non_nullable
as bool,panVerified: null == panVerified ? _self.panVerified : panVerified // ignore: cast_nullable_to_non_nullable
as bool,bankVerified: null == bankVerified ? _self.bankVerified : bankVerified // ignore: cast_nullable_to_non_nullable
as bool,selfieVerified: null == selfieVerified ? _self.selfieVerified : selfieVerified // ignore: cast_nullable_to_non_nullable
as bool,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,resubmissionAllowedAt: freezed == resubmissionAllowedAt ? _self.resubmissionAllowedAt : resubmissionAllowedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AadhaarOtpSession {

@JsonKey(name: 'session_id') String get sessionId;@JsonKey(name: 'expires_in_seconds') int get expiresInSeconds;
/// Create a copy of AadhaarOtpSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AadhaarOtpSessionCopyWith<AadhaarOtpSession> get copyWith => _$AadhaarOtpSessionCopyWithImpl<AadhaarOtpSession>(this as AadhaarOtpSession, _$identity);

  /// Serializes this AadhaarOtpSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AadhaarOtpSession&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.expiresInSeconds, expiresInSeconds) || other.expiresInSeconds == expiresInSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionId,expiresInSeconds);

@override
String toString() {
  return 'AadhaarOtpSession(sessionId: $sessionId, expiresInSeconds: $expiresInSeconds)';
}


}

/// @nodoc
abstract mixin class $AadhaarOtpSessionCopyWith<$Res>  {
  factory $AadhaarOtpSessionCopyWith(AadhaarOtpSession value, $Res Function(AadhaarOtpSession) _then) = _$AadhaarOtpSessionCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'session_id') String sessionId,@JsonKey(name: 'expires_in_seconds') int expiresInSeconds
});




}
/// @nodoc
class _$AadhaarOtpSessionCopyWithImpl<$Res>
    implements $AadhaarOtpSessionCopyWith<$Res> {
  _$AadhaarOtpSessionCopyWithImpl(this._self, this._then);

  final AadhaarOtpSession _self;
  final $Res Function(AadhaarOtpSession) _then;

/// Create a copy of AadhaarOtpSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,Object? expiresInSeconds = null,}) {
  return _then(_self.copyWith(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,expiresInSeconds: null == expiresInSeconds ? _self.expiresInSeconds : expiresInSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AadhaarOtpSession].
extension AadhaarOtpSessionPatterns on AadhaarOtpSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AadhaarOtpSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AadhaarOtpSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AadhaarOtpSession value)  $default,){
final _that = this;
switch (_that) {
case _AadhaarOtpSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AadhaarOtpSession value)?  $default,){
final _that = this;
switch (_that) {
case _AadhaarOtpSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'expires_in_seconds')  int expiresInSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AadhaarOtpSession() when $default != null:
return $default(_that.sessionId,_that.expiresInSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'expires_in_seconds')  int expiresInSeconds)  $default,) {final _that = this;
switch (_that) {
case _AadhaarOtpSession():
return $default(_that.sessionId,_that.expiresInSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'expires_in_seconds')  int expiresInSeconds)?  $default,) {final _that = this;
switch (_that) {
case _AadhaarOtpSession() when $default != null:
return $default(_that.sessionId,_that.expiresInSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AadhaarOtpSession implements AadhaarOtpSession {
  const _AadhaarOtpSession({@JsonKey(name: 'session_id') required this.sessionId, @JsonKey(name: 'expires_in_seconds') required this.expiresInSeconds});
  factory _AadhaarOtpSession.fromJson(Map<String, dynamic> json) => _$AadhaarOtpSessionFromJson(json);

@override@JsonKey(name: 'session_id') final  String sessionId;
@override@JsonKey(name: 'expires_in_seconds') final  int expiresInSeconds;

/// Create a copy of AadhaarOtpSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AadhaarOtpSessionCopyWith<_AadhaarOtpSession> get copyWith => __$AadhaarOtpSessionCopyWithImpl<_AadhaarOtpSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AadhaarOtpSessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AadhaarOtpSession&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.expiresInSeconds, expiresInSeconds) || other.expiresInSeconds == expiresInSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionId,expiresInSeconds);

@override
String toString() {
  return 'AadhaarOtpSession(sessionId: $sessionId, expiresInSeconds: $expiresInSeconds)';
}


}

/// @nodoc
abstract mixin class _$AadhaarOtpSessionCopyWith<$Res> implements $AadhaarOtpSessionCopyWith<$Res> {
  factory _$AadhaarOtpSessionCopyWith(_AadhaarOtpSession value, $Res Function(_AadhaarOtpSession) _then) = __$AadhaarOtpSessionCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'session_id') String sessionId,@JsonKey(name: 'expires_in_seconds') int expiresInSeconds
});




}
/// @nodoc
class __$AadhaarOtpSessionCopyWithImpl<$Res>
    implements _$AadhaarOtpSessionCopyWith<$Res> {
  __$AadhaarOtpSessionCopyWithImpl(this._self, this._then);

  final _AadhaarOtpSession _self;
  final $Res Function(_AadhaarOtpSession) _then;

/// Create a copy of AadhaarOtpSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? expiresInSeconds = null,}) {
  return _then(_AadhaarOtpSession(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,expiresInSeconds: null == expiresInSeconds ? _self.expiresInSeconds : expiresInSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$KycSubmitResponse {

@JsonKey(name: 'kyc_status') String get kycStatus;@JsonKey(name: 'estimated_completion') String get estimatedCompletion;
/// Create a copy of KycSubmitResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KycSubmitResponseCopyWith<KycSubmitResponse> get copyWith => _$KycSubmitResponseCopyWithImpl<KycSubmitResponse>(this as KycSubmitResponse, _$identity);

  /// Serializes this KycSubmitResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KycSubmitResponse&&(identical(other.kycStatus, kycStatus) || other.kycStatus == kycStatus)&&(identical(other.estimatedCompletion, estimatedCompletion) || other.estimatedCompletion == estimatedCompletion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kycStatus,estimatedCompletion);

@override
String toString() {
  return 'KycSubmitResponse(kycStatus: $kycStatus, estimatedCompletion: $estimatedCompletion)';
}


}

/// @nodoc
abstract mixin class $KycSubmitResponseCopyWith<$Res>  {
  factory $KycSubmitResponseCopyWith(KycSubmitResponse value, $Res Function(KycSubmitResponse) _then) = _$KycSubmitResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'kyc_status') String kycStatus,@JsonKey(name: 'estimated_completion') String estimatedCompletion
});




}
/// @nodoc
class _$KycSubmitResponseCopyWithImpl<$Res>
    implements $KycSubmitResponseCopyWith<$Res> {
  _$KycSubmitResponseCopyWithImpl(this._self, this._then);

  final KycSubmitResponse _self;
  final $Res Function(KycSubmitResponse) _then;

/// Create a copy of KycSubmitResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kycStatus = null,Object? estimatedCompletion = null,}) {
  return _then(_self.copyWith(
kycStatus: null == kycStatus ? _self.kycStatus : kycStatus // ignore: cast_nullable_to_non_nullable
as String,estimatedCompletion: null == estimatedCompletion ? _self.estimatedCompletion : estimatedCompletion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [KycSubmitResponse].
extension KycSubmitResponsePatterns on KycSubmitResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KycSubmitResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KycSubmitResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KycSubmitResponse value)  $default,){
final _that = this;
switch (_that) {
case _KycSubmitResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KycSubmitResponse value)?  $default,){
final _that = this;
switch (_that) {
case _KycSubmitResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'kyc_status')  String kycStatus, @JsonKey(name: 'estimated_completion')  String estimatedCompletion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KycSubmitResponse() when $default != null:
return $default(_that.kycStatus,_that.estimatedCompletion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'kyc_status')  String kycStatus, @JsonKey(name: 'estimated_completion')  String estimatedCompletion)  $default,) {final _that = this;
switch (_that) {
case _KycSubmitResponse():
return $default(_that.kycStatus,_that.estimatedCompletion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'kyc_status')  String kycStatus, @JsonKey(name: 'estimated_completion')  String estimatedCompletion)?  $default,) {final _that = this;
switch (_that) {
case _KycSubmitResponse() when $default != null:
return $default(_that.kycStatus,_that.estimatedCompletion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KycSubmitResponse implements KycSubmitResponse {
  const _KycSubmitResponse({@JsonKey(name: 'kyc_status') required this.kycStatus, @JsonKey(name: 'estimated_completion') required this.estimatedCompletion});
  factory _KycSubmitResponse.fromJson(Map<String, dynamic> json) => _$KycSubmitResponseFromJson(json);

@override@JsonKey(name: 'kyc_status') final  String kycStatus;
@override@JsonKey(name: 'estimated_completion') final  String estimatedCompletion;

/// Create a copy of KycSubmitResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KycSubmitResponseCopyWith<_KycSubmitResponse> get copyWith => __$KycSubmitResponseCopyWithImpl<_KycSubmitResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KycSubmitResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KycSubmitResponse&&(identical(other.kycStatus, kycStatus) || other.kycStatus == kycStatus)&&(identical(other.estimatedCompletion, estimatedCompletion) || other.estimatedCompletion == estimatedCompletion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kycStatus,estimatedCompletion);

@override
String toString() {
  return 'KycSubmitResponse(kycStatus: $kycStatus, estimatedCompletion: $estimatedCompletion)';
}


}

/// @nodoc
abstract mixin class _$KycSubmitResponseCopyWith<$Res> implements $KycSubmitResponseCopyWith<$Res> {
  factory _$KycSubmitResponseCopyWith(_KycSubmitResponse value, $Res Function(_KycSubmitResponse) _then) = __$KycSubmitResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'kyc_status') String kycStatus,@JsonKey(name: 'estimated_completion') String estimatedCompletion
});




}
/// @nodoc
class __$KycSubmitResponseCopyWithImpl<$Res>
    implements _$KycSubmitResponseCopyWith<$Res> {
  __$KycSubmitResponseCopyWithImpl(this._self, this._then);

  final _KycSubmitResponse _self;
  final $Res Function(_KycSubmitResponse) _then;

/// Create a copy of KycSubmitResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kycStatus = null,Object? estimatedCompletion = null,}) {
  return _then(_KycSubmitResponse(
kycStatus: null == kycStatus ? _self.kycStatus : kycStatus // ignore: cast_nullable_to_non_nullable
as String,estimatedCompletion: null == estimatedCompletion ? _self.estimatedCompletion : estimatedCompletion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
