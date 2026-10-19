// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_adjust/otel_adjust.dart';

/// Traces Adjust calls with OpenTelemetry.
///
/// `otel_adjust` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Adjust call in
/// [tracedAdjust]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'adjust-example');

  // Wraps an Adjust SDK call in a CLIENT span.
  final adjustId = await tracedAdjust<String>(
    operation: 'create',
    invoke: () async {
      // Make the Adjust call here, then report what it returned.
      const id = 'adjust_8f3a2c';
      return const AdjustCallResult(
          value: id,
          result: AdjustResult(
              appToken: 'abc123def456',
              environment: 'sandbox',
              adid: 'ad_8f3a2c',
              idfa: 'example',
              gpsAdid: 'gpsad_8f3a2c',
              trackerName: 'example',
              trackerToken: 'example',
              network: 'example',
              campaign: 'example',
              adgroup: 'example',
              creative: 'example',
              clickLabel: 'click_label',
              eventToken: 'order.created',
              revenue: 0.5,
              currency: 'usd',
              callbackId: 'callback_8f3a2c',
              attEnabled: true,
              attStatus: 201,
              errorCode: 1,
              errorMessage: 'example',
              statusCode: 201));
    },
  );
  OTelLog.info('tracedAdjust create returned $adjustId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutAdjustInstrumentationAsync.
  await runWithoutAdjustInstrumentationAsync(
    () => tracedAdjust<String>(
      operation: 'create',
      invoke: () async {
        const id = 'adjust_8f3a2c';
        return const AdjustCallResult(
            value: id,
            result: AdjustResult(
                appToken: 'abc123def456',
                environment: 'sandbox',
                adid: 'ad_8f3a2c',
                idfa: 'example',
                gpsAdid: 'gpsad_8f3a2c',
                trackerName: 'example',
                trackerToken: 'example',
                network: 'example',
                campaign: 'example',
                adgroup: 'example',
                creative: 'example',
                clickLabel: 'click_label',
                eventToken: 'order.created',
                revenue: 0.5,
                currency: 'usd',
                callbackId: 'callback_8f3a2c',
                attEnabled: true,
                attStatus: 201,
                errorCode: 1,
                errorMessage: 'example',
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
