// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_adjust_suppression.dart';

const _tracerName = 'dartastic_otel_libs_adjust';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class AdjustResult {
  const AdjustResult({
    this.appToken,
    this.environment,
    this.adid,
    this.idfa,
    this.gpsAdid,
    this.trackerName,
    this.trackerToken,
    this.network,
    this.campaign,
    this.adgroup,
    this.creative,
    this.clickLabel,
    this.eventToken,
    this.revenue,
    this.currency,
    this.callbackId,
    this.attEnabled,
    this.attStatus,
    this.errorCode,
    this.errorMessage,
    this.statusCode,
  });

  /// Adjust app token (`abc123def456`).
  final String? appToken;

  /// `sandbox` / `production`.
  final String? environment;

  /// Adjust device id.
  final String? adid;

  /// Apple IDFA when available.
  final String? idfa;

  /// Google Play Services advertising id when available.
  final String? gpsAdid;

  final String? trackerName;
  final String? trackerToken;

  /// Network parent in tracker hierarchy (e.g., `Facebook Installs`).
  final String? network;

  final String? campaign;
  final String? adgroup;
  final String? creative;

  /// `click_label` from URL.
  final String? clickLabel;

  /// 6-character event token (event identifier in Adjust dashboard).
  final String? eventToken;

  final double? revenue;
  final String? currency;

  /// Custom callback id passed with the event.
  final String? callbackId;

  /// `true` when Adjust requested ATT and got authorization.
  final bool? attEnabled;

  /// `0` not_determined / `1` restricted / `2` denied / `3` authorized.
  final int? attStatus;

  final int? errorCode;
  final String? errorMessage;

  final int? statusCode;
}

class AdjustCallResult<T> {
  const AdjustCallResult({required this.value, this.result});
  final T value;
  final AdjustResult? result;
}

/// Wraps an Adjust SDK call in a CLIENT span. [operation] is one of
/// `initSdk`, `trackEvent`, `trackAdRevenue`, `trackThirdPartySharing`,
/// `trackMeasurementConsent`, `requestTrackingAuthorization`,
/// `getAttribution`, `getAdid`, `getIdfa`, `getIdfv`,
/// `getGoogleAdId`, `appWillOpenUrl`, `setOfflineMode`,
/// `verifyAppStorePurchase`, `verifyPlayStorePurchase`,
/// `disableThirdPartySharing`, `gdprForgetMe`.
Future<T> tracedAdjust<T>({
  required String operation,
  required Future<AdjustCallResult<T>> Function() invoke,
}) async {
  if (adjustInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'adjust',
    'rpc.method': operation,
    'adjust.operation': operation,
  };

  final span = _tracer().startSpan(
    'adjust $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.appToken != null) {
        extras.add(OTel.attributeString(
          'adjust.app.token',
          r.result!.appToken!,
        ));
      }
      if (r.result!.environment != null) {
        extras.add(OTel.attributeString(
          'adjust.environment',
          r.result!.environment!,
        ));
      }
      if (r.result!.adid != null) {
        extras.add(OTel.attributeString('adjust.adid', r.result!.adid!));
      }
      if (r.result!.idfa != null) {
        extras.add(OTel.attributeString('adjust.idfa', r.result!.idfa!));
      }
      if (r.result!.gpsAdid != null) {
        extras.add(OTel.attributeString(
          'adjust.gps_adid',
          r.result!.gpsAdid!,
        ));
      }
      if (r.result!.trackerName != null) {
        extras.add(OTel.attributeString(
          'adjust.tracker.name',
          r.result!.trackerName!,
        ));
      }
      if (r.result!.trackerToken != null) {
        extras.add(OTel.attributeString(
          'adjust.tracker.token',
          r.result!.trackerToken!,
        ));
      }
      if (r.result!.network != null) {
        extras.add(OTel.attributeString(
          'adjust.network',
          r.result!.network!,
        ));
      }
      if (r.result!.campaign != null) {
        extras.add(OTel.attributeString(
          'adjust.campaign',
          r.result!.campaign!,
        ));
      }
      if (r.result!.adgroup != null) {
        extras.add(OTel.attributeString(
          'adjust.adgroup',
          r.result!.adgroup!,
        ));
      }
      if (r.result!.creative != null) {
        extras.add(OTel.attributeString(
          'adjust.creative',
          r.result!.creative!,
        ));
      }
      if (r.result!.clickLabel != null) {
        extras.add(OTel.attributeString(
          'adjust.click_label',
          r.result!.clickLabel!,
        ));
      }
      if (r.result!.eventToken != null) {
        extras.add(OTel.attributeString(
          'adjust.event.token',
          r.result!.eventToken!,
        ));
      }
      if (r.result!.revenue != null) {
        extras.add(OTel.attributeDouble(
          'adjust.event.revenue',
          r.result!.revenue!,
        ));
      }
      if (r.result!.currency != null) {
        extras.add(OTel.attributeString(
          'adjust.event.currency',
          r.result!.currency!,
        ));
      }
      if (r.result!.callbackId != null) {
        extras.add(OTel.attributeString(
          'adjust.event.callback_id',
          r.result!.callbackId!,
        ));
      }
      if (r.result!.attEnabled != null) {
        extras.add(OTel.attributeBool(
          'adjust.att.enabled',
          r.result!.attEnabled!,
        ));
      }
      if (r.result!.attStatus != null) {
        extras.add(OTel.attributeInt(
          'adjust.att.status',
          r.result!.attStatus!,
        ));
      }
      if (r.result!.errorCode != null) {
        extras.add(OTel.attributeInt(
          'adjust.error.code',
          r.result!.errorCode!,
        ));
        span.setStatus(
          SpanStatusCode.Error,
          'Adjust error ${r.result!.errorCode}',
        );
      }
      if (r.result!.errorMessage != null) {
        extras.add(OTel.attributeString(
          'adjust.error.message',
          r.result!.errorMessage!,
        ));
      }
      if (r.result!.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Adjust HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
