// vi: syntax=cpp
/* Heart beat monitor
 *  Macro Parameters:
 *   TODO
*/

program HeartbeatMonitor("name=HeartbeatMonitor, HEARTBEAT_PV=,HEART_RATE=")

%%#include <stdlib.h>
%%#include "epicsTime.h"

option +c;  /* connect to PVs before starting */
option +r;  /* re-entrant mode (for more than one instance) */
option +s;  /* safe mode */
option +d;  /* debug mode */

int heartbeat;       assign heartbeat to     "{HEARTBEAT_PV}";    monitor heartbeat;
int initialized;     assign initialized to   "{INITIALIZED_PV}";
int latch_alarm;     assign latch_alarm to   "{LATCH_ALARM_PV}";
int skipped_beat;    assign skipped_beat to  "{SKIPPED_BEAT_PV}";

int last_beat;
int max_skipped_beats;
int num_skipped_beats;

float bygones = 0.0f;
float expected_heartrate = 0.0f;
float skipped_beat_threshold = 0.0f;

char *macro_bygones;
char *macro_heartbeat_pv;
char *macro_heartrate;
char *macro_initialized_pv;
char *macro_latch_alarm_pv;
char *macro_max_skipped_beats;
char *macro_skipped_beat_pv;
void *ts_last_skipped_beat;


ss HeartbeatMonitor {
    state Init {
        entry {
            macro_bygones = macValueGet("BYGONES");
            macro_heartbeat_pv = macValueGet("HEARTBEAT_PV");
            macro_heartrate = macValueGet("HEART_RATE");
            macro_initialized_pv = macValueGet("INITIALIZED_PV");
            macro_latch_alarm_pv = macValueGet("LATCH_ALARM_PV");
            macro_max_skipped_beats = macValueGet("MAX_SKIPPED");
            macro_skipped_beat_pv = macValueGet("SKIPPED_BEAT_PV");

            last_beat = 0;
            num_skipped_beats = 0;
            %% pVar->ts_last_skipped_beat = malloc(sizeof(epicsTimeStamp));

            printf("Heartbeat monitor configuration:\n");
            printf("    Heartbeat PV:       %s\n", (macro_heartbeat_pv    ? macro_heartbeat_pv : ""));
            printf("    Expected rate:      %s\n", (macro_heartrate       ? macro_heartrate : ""));
            printf("    Latch alarm PV:     %s\n", (macro_latch_alarm_pv  ? macro_latch_alarm_pv : ""));
            printf("    Skipped beat PV:    %s\n", (macro_skipped_beat_pv ? macro_skipped_beat_pv : ""));
            printf("    Initialized PV:     %s\n", (macro_initialized_pv  ? macro_initialized_pv : ""));
            printf("    Bygones:            %s\n", (macro_bygones  ? macro_bygones : ""));
            printf("    Max skipped beats:  %s\n", (macro_max_skipped_beats ? macro_max_skipped_beats : ""));

            if (macro_heartrate != NULL) {
                expected_heartrate = atof(macro_heartrate);
                skipped_beat_threshold = expected_heartrate * 1.5f;
            }

            if (macro_bygones != NULL) {
                bygones = atof(macro_bygones);
            } else {
                bygones = 0.0f;
            }

            if (macro_max_skipped_beats != NULL) {
                max_skipped_beats = atoi(macro_max_skipped_beats);
            } else {
                max_skipped_beats = 0;
            }
        }

        when (skipped_beat_threshold <= 0.0 ||
              max_skipped_beats < 0 ||
              bygones < expected_heartrate ||
              !macro_heartbeat_pv ||
              !macro_latch_alarm_pv ||
              !macro_skipped_beat_pv ||
              !macro_initialized_pv)
        {
        } state ConfigurationError

        when (heartbeat == 0) {
            initialized = 1;
            pvPut(initialized, SYNC);
        } state HeartbeatZero

        when (heartbeat == 1) {
            initialized = 1;
            pvPut(initialized, SYNC);
        } state HeartbeatOne
    }

    state ConfigurationError {
        entry {
            printf("\n\n!!! Heartbeat monitor configuration error! Latching alarm.\n\n");
            latch_alarm = 1;
            pvPut(latch_alarm);
            epicsThreadSleep(1);
        }

        when (delay(1)) {
        } state ConfigurationError
    }

    state HeartbeatZero {
        entry {
            last_beat = 0;
        }

        when (heartbeat == 1) {
        } state HeartbeatOne

        when (pvSeverity(heartbeat) != pvSevrOK || delay(skipped_beat_threshold)) {
        } state SkippedABeat
    }

    state HeartbeatOne {
        entry {
            last_beat = 1;
        }

        when (heartbeat == 0) {
        } state HeartbeatZero

        when (pvSeverity(heartbeat) != pvSevrOK || delay(skipped_beat_threshold)) {
        } state SkippedABeat
    }

    state SkippedABeat {
        entry {
            skipped_beat = 1;
            pvPut(skipped_beat, SYNC);

            %{
                epicsTimeStamp ts_now;
                epicsTimeGetCurrent(&ts_now);

                epicsTimeStamp *last_skipped_beat = (epicsTimeStamp*)pVar->ts_last_skipped_beat;
                double dt = epicsTimeDiffInSeconds(&ts_now, last_skipped_beat);
                *last_skipped_beat = ts_now;
            }%
            if (dt > bygones) {
                num_skipped_beats = 1;
                printf("Let bygones be bygones... (%f sec > %f sec)", dt, bygones);
            } else {
                num_skipped_beats++;
            }
            printf("Total skipped beats: %d\n", num_skipped_beats);

            if (num_skipped_beats > max_skipped_beats) {
                latch_alarm = 1;
                pvPut(latch_alarm, SYNC);
            }
        }

        when (delay(expected_heartrate)) {
        } state SkippedAnotherBeat

        when (pvSeverity(heartbeat) == pvSevrOK && heartbeat == 0 && heartbeat != last_beat) {
        } state HeartbeatZero

        when (pvSeverity(heartbeat) == pvSevrOK && heartbeat == 1 && heartbeat != last_beat) {
        } state HeartbeatOne
    }

    state SkippedAnotherBeat {
        when () {
        } state SkippedABeat
    }
}
