// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_adjust/otel_adjust.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_adjust-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('getAttribution records tracker hierarchy', () async {
    await tracedAdjust<String>(
      operation: 'getAttribution',
      invoke: () async => const AdjustCallResult(
        value: 'ok',
        result: AdjustResult(
          environment: 'production',
          trackerToken: 'abc123',
          network: 'Facebook Installs',
          campaign: 'spring_2026',
          adgroup: 'ios_users',
          creative: 'square_video',
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('adjust getAttribution')!);
    expect(a['adjust.network'], 'Facebook Installs');
    expect(a['adjust.campaign'], 'spring_2026');
    expect(a['adjust.creative'], 'square_video');
  });

  test('trackEvent records token + revenue + callback', () async {
    await tracedAdjust<String>(
      operation: 'trackEvent',
      invoke: () async => const AdjustCallResult(
        value: 'ok',
        result: AdjustResult(
          eventToken: 'pur_01',
          revenue: 9.99,
          currency: 'USD',
          callbackId: 'order_42',
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('adjust trackEvent')!);
    expect(a['adjust.event.token'], 'pur_01');
    expect(a['adjust.event.revenue'], 9.99);
    expect(a['adjust.event.callback_id'], 'order_42');
  });

  test('ATT denied records status', () async {
    await tracedAdjust<String>(
      operation: 'requestTrackingAuthorization',
      invoke: () async => const AdjustCallResult(
        value: 'ok',
        result: AdjustResult(
          attEnabled: false,
          attStatus: 2,
        ),
      ),
    );
    final a = attrsOf(
      spans.findSpanByName('adjust requestTrackingAuthorization')!,
    );
    expect(a['adjust.att.enabled'], false);
    expect(a['adjust.att.status'], 2);
  });

  test('error sets span error', () async {
    await tracedAdjust<String>(
      operation: 'verifyAppStorePurchase',
      invoke: () async => const AdjustCallResult(
        value: 'ok',
        result: AdjustResult(
          errorCode: 102,
          errorMessage: 'Invalid receipt',
        ),
      ),
    );
    expect(
      spans.findSpanByName('adjust verifyAppStorePurchase')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutAdjustInstrumentationAsync(() async {
      await tracedAdjust<String>(
        operation: 'initSdk',
        invoke: () async => const AdjustCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('adjust '), isEmpty);
  });
}
