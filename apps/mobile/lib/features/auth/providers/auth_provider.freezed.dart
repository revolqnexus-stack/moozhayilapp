// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthState {

 AuthFlowStep get step; User? get user; OtpChallenge? get otpChallenge; String get phone; String get otp; bool get otpSendInProgress; Object? get sendOtpError; bool get otpVerifyInProgress; Object? get verifyOtpError;
/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthStateCopyWith<AuthState> get copyWith => _$AuthStateCopyWithImpl<AuthState>(this as AuthState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthState&&(identical(other.step, step) || other.step == step)&&(identical(other.user, user) || other.user == user)&&(identical(other.otpChallenge, otpChallenge) || other.otpChallenge == otpChallenge)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.otp, otp) || other.otp == otp)&&(identical(other.otpSendInProgress, otpSendInProgress) || other.otpSendInProgress == otpSendInProgress)&&const DeepCollectionEquality().equals(other.sendOtpError, sendOtpError)&&(identical(other.otpVerifyInProgress, otpVerifyInProgress) || other.otpVerifyInProgress == otpVerifyInProgress)&&const DeepCollectionEquality().equals(other.verifyOtpError, verifyOtpError));
}


@override
int get hashCode => Object.hash(runtimeType,step,user,otpChallenge,phone,otp,otpSendInProgress,const DeepCollectionEquality().hash(sendOtpError),otpVerifyInProgress,const DeepCollectionEquality().hash(verifyOtpError));

@override
String toString() {
  return 'AuthState(step: $step, user: $user, otpChallenge: $otpChallenge, phone: $phone, otp: $otp, otpSendInProgress: $otpSendInProgress, sendOtpError: $sendOtpError, otpVerifyInProgress: $otpVerifyInProgress, verifyOtpError: $verifyOtpError)';
}


}

/// @nodoc
abstract mixin class $AuthStateCopyWith<$Res>  {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) _then) = _$AuthStateCopyWithImpl;
@useResult
$Res call({
 AuthFlowStep step, User? user, OtpChallenge? otpChallenge, String phone, String otp, bool otpSendInProgress, Object? sendOtpError, bool otpVerifyInProgress, Object? verifyOtpError
});


$UserCopyWith<$Res>? get user;$OtpChallengeCopyWith<$Res>? get otpChallenge;

}
/// @nodoc
class _$AuthStateCopyWithImpl<$Res>
    implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._self, this._then);

  final AuthState _self;
  final $Res Function(AuthState) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? step = null,Object? user = freezed,Object? otpChallenge = freezed,Object? phone = null,Object? otp = null,Object? otpSendInProgress = null,Object? sendOtpError = freezed,Object? otpVerifyInProgress = null,Object? verifyOtpError = freezed,}) {
  return _then(_self.copyWith(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as AuthFlowStep,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User?,otpChallenge: freezed == otpChallenge ? _self.otpChallenge : otpChallenge // ignore: cast_nullable_to_non_nullable
as OtpChallenge?,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,otp: null == otp ? _self.otp : otp // ignore: cast_nullable_to_non_nullable
as String,otpSendInProgress: null == otpSendInProgress ? _self.otpSendInProgress : otpSendInProgress // ignore: cast_nullable_to_non_nullable
as bool,sendOtpError: freezed == sendOtpError ? _self.sendOtpError : sendOtpError ,otpVerifyInProgress: null == otpVerifyInProgress ? _self.otpVerifyInProgress : otpVerifyInProgress // ignore: cast_nullable_to_non_nullable
as bool,verifyOtpError: freezed == verifyOtpError ? _self.verifyOtpError : verifyOtpError ,
  ));
}
/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OtpChallengeCopyWith<$Res>? get otpChallenge {
    if (_self.otpChallenge == null) {
    return null;
  }

  return $OtpChallengeCopyWith<$Res>(_self.otpChallenge!, (value) {
    return _then(_self.copyWith(otpChallenge: value));
  });
}
}


/// Adds pattern-matching-related methods to [AuthState].
extension AuthStatePatterns on AuthState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthState value)  $default,){
final _that = this;
switch (_that) {
case _AuthState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthState value)?  $default,){
final _that = this;
switch (_that) {
case _AuthState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AuthFlowStep step,  User? user,  OtpChallenge? otpChallenge,  String phone,  String otp,  bool otpSendInProgress,  Object? sendOtpError,  bool otpVerifyInProgress,  Object? verifyOtpError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthState() when $default != null:
return $default(_that.step,_that.user,_that.otpChallenge,_that.phone,_that.otp,_that.otpSendInProgress,_that.sendOtpError,_that.otpVerifyInProgress,_that.verifyOtpError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AuthFlowStep step,  User? user,  OtpChallenge? otpChallenge,  String phone,  String otp,  bool otpSendInProgress,  Object? sendOtpError,  bool otpVerifyInProgress,  Object? verifyOtpError)  $default,) {final _that = this;
switch (_that) {
case _AuthState():
return $default(_that.step,_that.user,_that.otpChallenge,_that.phone,_that.otp,_that.otpSendInProgress,_that.sendOtpError,_that.otpVerifyInProgress,_that.verifyOtpError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AuthFlowStep step,  User? user,  OtpChallenge? otpChallenge,  String phone,  String otp,  bool otpSendInProgress,  Object? sendOtpError,  bool otpVerifyInProgress,  Object? verifyOtpError)?  $default,) {final _that = this;
switch (_that) {
case _AuthState() when $default != null:
return $default(_that.step,_that.user,_that.otpChallenge,_that.phone,_that.otp,_that.otpSendInProgress,_that.sendOtpError,_that.otpVerifyInProgress,_that.verifyOtpError);case _:
  return null;

}
}

}

/// @nodoc


class _AuthState implements AuthState {
  const _AuthState({this.step = AuthFlowStep.signedOut, this.user, this.otpChallenge, this.phone = '', this.otp = '', this.otpSendInProgress = false, this.sendOtpError, this.otpVerifyInProgress = false, this.verifyOtpError});
  

@override@JsonKey() final  AuthFlowStep step;
@override final  User? user;
@override final  OtpChallenge? otpChallenge;
@override@JsonKey() final  String phone;
@override@JsonKey() final  String otp;
@override@JsonKey() final  bool otpSendInProgress;
@override final  Object? sendOtpError;
@override@JsonKey() final  bool otpVerifyInProgress;
@override final  Object? verifyOtpError;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthStateCopyWith<_AuthState> get copyWith => __$AuthStateCopyWithImpl<_AuthState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthState&&(identical(other.step, step) || other.step == step)&&(identical(other.user, user) || other.user == user)&&(identical(other.otpChallenge, otpChallenge) || other.otpChallenge == otpChallenge)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.otp, otp) || other.otp == otp)&&(identical(other.otpSendInProgress, otpSendInProgress) || other.otpSendInProgress == otpSendInProgress)&&const DeepCollectionEquality().equals(other.sendOtpError, sendOtpError)&&(identical(other.otpVerifyInProgress, otpVerifyInProgress) || other.otpVerifyInProgress == otpVerifyInProgress)&&const DeepCollectionEquality().equals(other.verifyOtpError, verifyOtpError));
}


@override
int get hashCode => Object.hash(runtimeType,step,user,otpChallenge,phone,otp,otpSendInProgress,const DeepCollectionEquality().hash(sendOtpError),otpVerifyInProgress,const DeepCollectionEquality().hash(verifyOtpError));

@override
String toString() {
  return 'AuthState(step: $step, user: $user, otpChallenge: $otpChallenge, phone: $phone, otp: $otp, otpSendInProgress: $otpSendInProgress, sendOtpError: $sendOtpError, otpVerifyInProgress: $otpVerifyInProgress, verifyOtpError: $verifyOtpError)';
}


}

/// @nodoc
abstract mixin class _$AuthStateCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory _$AuthStateCopyWith(_AuthState value, $Res Function(_AuthState) _then) = __$AuthStateCopyWithImpl;
@override @useResult
$Res call({
 AuthFlowStep step, User? user, OtpChallenge? otpChallenge, String phone, String otp, bool otpSendInProgress, Object? sendOtpError, bool otpVerifyInProgress, Object? verifyOtpError
});


@override $UserCopyWith<$Res>? get user;@override $OtpChallengeCopyWith<$Res>? get otpChallenge;

}
/// @nodoc
class __$AuthStateCopyWithImpl<$Res>
    implements _$AuthStateCopyWith<$Res> {
  __$AuthStateCopyWithImpl(this._self, this._then);

  final _AuthState _self;
  final $Res Function(_AuthState) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? step = null,Object? user = freezed,Object? otpChallenge = freezed,Object? phone = null,Object? otp = null,Object? otpSendInProgress = null,Object? sendOtpError = freezed,Object? otpVerifyInProgress = null,Object? verifyOtpError = freezed,}) {
  return _then(_AuthState(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as AuthFlowStep,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User?,otpChallenge: freezed == otpChallenge ? _self.otpChallenge : otpChallenge // ignore: cast_nullable_to_non_nullable
as OtpChallenge?,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,otp: null == otp ? _self.otp : otp // ignore: cast_nullable_to_non_nullable
as String,otpSendInProgress: null == otpSendInProgress ? _self.otpSendInProgress : otpSendInProgress // ignore: cast_nullable_to_non_nullable
as bool,sendOtpError: freezed == sendOtpError ? _self.sendOtpError : sendOtpError ,otpVerifyInProgress: null == otpVerifyInProgress ? _self.otpVerifyInProgress : otpVerifyInProgress // ignore: cast_nullable_to_non_nullable
as bool,verifyOtpError: freezed == verifyOtpError ? _self.verifyOtpError : verifyOtpError ,
  ));
}

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OtpChallengeCopyWith<$Res>? get otpChallenge {
    if (_self.otpChallenge == null) {
    return null;
  }

  return $OtpChallengeCopyWith<$Res>(_self.otpChallenge!, (value) {
    return _then(_self.copyWith(otpChallenge: value));
  });
}
}

// dart format on
