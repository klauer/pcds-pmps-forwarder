#!/usr/bin/env python3
import logging
from caproto.server import pvproperty, PVGroup, ioc_arg_parser, run


logger = logging.getLogger('caproto')


class HeartbeatGroup(PVGroup):
    heartbeat = pvproperty(value=0, mock_record='bo', read_only=True)
    beat_id = pvproperty(value=0, mock_record='longin', read_only=True)
    beat_pattern = pvproperty(value=[0, 1, 1,
                                     1, 1, 1],
                              max_length=1024)

    @heartbeat.scan(period=0.5, use_scan_field=True)
    async def heartbeat(self, instance, async_lib):
        beat_id = self.beat_id.value + 1
        await self.beat_id.write(beat_id)
        beat_pattern = self.beat_pattern.value
        if not beat_pattern[beat_id % len(beat_pattern)]:
            return

        await instance.write(beat_id % 2)

    @beat_pattern.startup
    async def beat_pattern(self, instance, async_lib):
        scan = self.heartbeat.fields['SCAN']
        try:
            await scan.write('.5 second')
        except TypeError:
            # TODO: old caproto compat
            scan._data['value'] = scan.enum_strings.index('.5 second')


if __name__ == '__main__':
    ioc_options, run_options = ioc_arg_parser(
        default_prefix='TST:PMPS:HEART:',
        desc='Accelerator IOC heartbeat simulator for PMPS',
    )

    ioc = HeartbeatGroup(**ioc_options)
    run(ioc.pvdb, **run_options)
