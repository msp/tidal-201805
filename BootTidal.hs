-- Doctored from https://github.com/tidalcycles/Tidal/blob/main/BootTidal.hs
-- doesn't seem to parse multi-line input!

:set -XOverloadedStrings
:set prompt ""

import Sound.Tidal.Context

import System.IO (hSetEncoding, stdout, utf8)

import qualified Control.Concurrent.MVar as MV
import qualified Sound.Tidal.Tempo as Tempo
-- import qualified Sound.OSC.FD as O

hSetEncoding stdout utf8

-- squattybox2
-- processingTarget = OSCTarget {oName = "Processing Target", oAddress = "192.168.86.132", oPort = 1818, oPath = "/play2", oShape = Nothing, oLatency = latency, oPreamble = [], oTimestamp = NoStamp }
-- horus
-- processingTarget = OSCTarget {oName = "Processing Target", oAddress = "192.168.86.221", oPort = 1818, oPath = "/play2", oShape = Nothing, oLatency = latency, oPreamble = [], oTimestamp = NoStamp }

-- rpiTarget = OSCTarget {oName = "RPI Target", oAddress = "192.168.0.103", oPort = 5005, oPath = "/play2", oShape = Nothing, oLatency = latency, oPreamble = [], oTimestamp = NoStamp }
-- rpiTarget = OSCTarget {oName = "RPI2 Target", oAddress = "192.168.0.104", oPort = 5005, oPath = "/play2", oShape = Nothing, oLatency = latency, oPreamble = [], oTimestamp = NoStamp }
-- rpiTarget = OSCTarget {oName = "RPI3 Target", oAddress = "192.168.0.105", oPort = 5005, oPath = "/play2", oShape = Nothing, oLatency = latency, oPreamble = [], oTimestamp = NoStamp }
-- rpiTarget = OSCTarget {oName = "RPI4 Target", oAddress = "192.168.0.106", oPort = 5005, oPath = "/play2", oShape = Nothing, oLatency = latency, oPreamble = [], oTimestamp = NoStamp }

-- targets = [supercolliderTarget]
-- targets = [supercolliderTarget,processingTarget]
-- targets = [supercolliderTarget,processingTarget, rpiTarget, rpi2Target, rpi3Target, rpi4Target]

-- total latency = oLatency + cFrameTimespan
tidal <- startTidal (superdirtTarget {oLatency = 0.1, oAddress = "127.0.0.1", oPort = 57120}) (defaultConfig {cFrameTimespan = 1/20})

-- TODO: update from: https://tidalcycles.org/index.php/Custom_OSC
-- tidal <- startMulti targets (defaultConfig {cFrameTimespan = 1/20})

:{
let only = (hush >>)
    p = streamReplace tidal
    hush = streamHush tidal
    panic = do hush
               once $ sound "superpanic"
    list = streamList tidal
    mute = streamMute tidal
    unmute = streamUnmute tidal
    unmuteAll = streamUnmuteAll tidal
    solo = streamSolo tidal
    unsolo = streamUnsolo tidal
    once = streamOnce tidal
    first = streamFirst tidal
    asap = once
    nudgeAll = streamNudgeAll tidal
    all = streamAll tidal
    resetCycles = streamResetCycles tidal
    setcps = asap . cps
    getcps = do tempo <- MV.readMVar $ sTempoMV tidal
                return $ Tempo.cps tempo
--    getnow = do tempo <- MV.readMVar $ sTempoMV tidal
--                now <- O.time
--                return $ fromRational $ Tempo.timeToCycles tempo now
    xfade i = transition tidal True (Sound.Tidal.Transition.xfadeIn 4) i
    xfadeIn i t = transition tidal True (Sound.Tidal.Transition.xfadeIn t) i
    histpan i t = transition tidal True (Sound.Tidal.Transition.histpan t) i
    wait i t = transition tidal True (Sound.Tidal.Transition.wait t) i
    waitT i f t = transition tidal True (Sound.Tidal.Transition.waitT f t) i
    jump i = transition tidal True (Sound.Tidal.Transition.jump) i
    jumpIn i t = transition tidal True (Sound.Tidal.Transition.jumpIn t) i
    jumpIn' i t = transition tidal True (Sound.Tidal.Transition.jumpIn' t) i
    jumpMod i t = transition tidal True (Sound.Tidal.Transition.jumpMod t) i
    mortal i lifespan release = transition tidal True (Sound.Tidal.Transition.mortal lifespan release) i
    interpolate i = transition tidal True (Sound.Tidal.Transition.interpolate) i
    interpolateIn i t = transition tidal True (Sound.Tidal.Transition.interpolateIn t) i
    clutch i = transition tidal True (Sound.Tidal.Transition.clutch) i
    clutchIn i t = transition tidal True (Sound.Tidal.Transition.clutchIn t) i
    anticipate i = transition tidal True (Sound.Tidal.Transition.anticipate) i
    anticipateIn i t = transition tidal True (Sound.Tidal.Transition.anticipateIn t) i
    forId i t = transition tidal False (Sound.Tidal.Transition.mortalOverlay t) i
    d1 = p 1 . (|< orbit 0)
    d2 = p 2 . (|< orbit 1)
    d3 = p 3 . (|< orbit 2)
    d4 = p 4 . (|< orbit 3)
    d5 = p 5 . (|< orbit 4)
    d6 = p 6 . (|< orbit 5)
    d7 = p 7 . (|< orbit 6)
    d8 = p 8 . (|< orbit 7)
    d9 = p 9 . (|< orbit 8)
    d10 = p 10 . (|< orbit 9)
    d11 = p 11 . (|< orbit 10)
    d12 = p 12 . (|< orbit 11)
    d13 = p 13
    d14 = p 14
    d15 = p 15
    d16 = p 16

    p1 = p 17
    p2 = p 18
    p3 = p 19
    p4 = p 20
    p5 = p 21
    p6 = p 22
    p7 = p 23
    p8 = p 24

    r1 = p 25
    r2 = p 26
    r3 = p 27
    r4 = p 28
    r5 = p 29
    r6 = p 30
    r7 = p 31
    r8 = p 32

    rate = 128
    myRate = 16
    silence = "~"

    -- I/O: multitrack recording
    -- Set Supercollider to output to Jack Router/Loopback
    --
    -- When using with UCX thru Live
    --
    out1 = 0
    out2 = out1 + 1
    out3 = out2 + 1
    out4 = out3 + 1
    out5 = out4 + 1
    out6 = out5 + 1
    out7 = out6 + 1
    out8 = out7 + 1
    out9 = out8 + 1
    out10 = out9 + 1
    out11 = out10 + 1
    out12 = out11 + 1
    out13 = out12 + 1
    out14 = out13 + 1
    out15 = out14 + 1
    out16 = out15 + 1

:}

:{
let setI = streamSetI tidal
    setF = streamSetF tidal
    setS = streamSetS tidal
    setR = streamSetI tidal
    setB = streamSetB tidal
:}

:set prompt "msptidal> "
:set prompt-cont ""
