import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ICCCMFocus
import XMonad.Hooks.ManageDocks (docks, avoidStruts)
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Layout.IM
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Reflect (reflectHoriz)
import XMonad.Layout.Spacing
import XMonad.Layout.SimplestFloat
import XMonad.Util.Run(hPutStrLn, spawnPipe)
import Data.Monoid
import Graphics.X11.ExtraTypes.XF86
import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal      = "urxvtc"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Width of the window border in pixels.
--
myBorderWidth   = 0

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces    = clickable . (map dzenEscape) $ ["main","net","dev","mpv","gimp","4","8","6","9"]
  where
    clickable w = [ "^ca(1,xdotool key super+" ++ show n ++ ")" ++ ws ++ "^ca()" | (i,ws) <- zip [1..] w, let n = i ]

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- launch dmenu
    , ((modm,               xK_p     ), spawn "sh ~/.dmenu.sh")

    -- launch gmrun
    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun")

    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_q     ), spawn "killall conky dzen2 trayer-srg; xmonad --recompile; xmonad --restart")

    , ((modm .|. shiftMask, xK_Delete), spawn "sh ~/.shutdown.sh")

    -- Volume control
    , ((0 , xF86XK_AudioLowerVolume), spawn "amixer -q set Master 5%-")
    , ((0 , xF86XK_AudioRaiseVolume), spawn "amixer -q set Master 5%+")
    , ((0 , xF86XK_AudioMute), spawn "amixer -q set Master toggle")
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout = onWorkspace (myWorkspaces !! 4) gimpLayout $ avoidStruts $
    (simplestFloat ||| tiled ||| Mirror tiled ||| Full)
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = spacing 4 $ Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 4/100
     gimpLayout = avoidStruts $
         withIM (0.11) (Role "gimp-toolbox") $
         reflectHoriz $
         withIM (0.15) (Role "gimp-dock") $
         (tiled ||| Full)

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll . concat $
    [ [ className =? c --> doFloat        | c <- myFloat ]
    , [ className =? c --> doCenterFloat  | c <- myCenterFloat ]
    , [ title     =? t --> doCenterFloat  | t <- myCenterFloatT ]
    , [ resource  =? r --> doIgnore       | r <- myIgnore ]
    , [ className =? c --> doIgnore       | c <- myIgnoreC ]
    , [ className =? c --> doShift      (myWorkspaces !! 1) | c <- netApp ]
    , [ className =? c --> doShift      (myWorkspaces !! 2) | c <- devApp ]
    , [ className =? c --> doShiftAndGo (myWorkspaces !! 3) | c <- mpvApp ]
    , [ className =? c --> doShiftAndGo (myWorkspaces !! 4) | c <- gimpApp ]
    , [ className =? c --> doShift      (myWorkspaces !! 5) | c <- miscApp ]
    , [ className =? c --> doShift      (myWorkspaces !! 6) | c <- officeApp ]
    , [ isFullscreen   --> doFullFloat ]
    , [ isDialog       --> doCenterFloat ]
    , [ (stringProperty "WM_WINDOW_ROLE" =? "app" <&&> className =? "google-chrome") --> doFloat ]
    , [ (stringProperty "WM_WINDOW_ROLE" =? "pop-up" <&&> className =? "google-chrome") --> doFloat ]
    , [ (stringProperty "WM_WINDOW_ROLE" =? "browser" <&&> className =? "google-chrome") --> doShift (myWorkspaces !! 1) ]
    , [ (stringProperty "WM_WINDOW_ROLE" =? "browser-window" <&&> className =? "whatsapp-desktop") --> doFloat ]
    ]
      where
        doShiftAndGo w  = doF (W.greedyView w) <+> doShift w
        myFloat         = [ "Nm-connection-editor", "Gnome-calculator", "xpad", "mpv"
                          , "VirtualBox", "Pidgin", "com-sun-javaws-Main", "Android SDK Manager" ]
        myCenterFloat   = [ "Gmrun", "Java", "gcr-prompter", "Gnome-mpv", "Gnome-terminal", "URxvt"
                          , "Pcsxr", "PCSXR", "SimpleScreenRecorder", "Peek", "file_properties", "Eog" ]
        myCenterFloatT  = [ "About Mozilla Firefox"
                          , "File Operation Progress"
                          , "sun-awt-X11-XFramePeer"]
        myIgnore        = [ "desktop_window" ]
        myIgnoreC       = [ "Xfce4-notifyd", "Hjsplit" ]
        devApp          = [ "Geany", "Eclipse", "Java", "Codeblocks", "jetbrains-studio" ]
        netApp          = [ "Firefox", "Google-chrome" ]
        gimpApp         = [ "Gimp", "Gimp-2.8" ]
        mpvApp          = [ "Gnome-mpv" ]
        miscApp         = [ "Inkscape" ]
        officeApp       = [ "libreoffice-startcenter", "libreoffice-writer"
                          , "libreoffice-calc", "libreoffice-impress"
                          , "libreoffice-draw", "libreoffice-math"]

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook h = dynamicLogWithPP $ defaultPP
    { ppCurrent          = dzenColor "#ffffff" "#606060" . pad
    , ppHidden           = dzenColor "#919191" "#444444" . pad
    , ppHiddenNoWindows  = dzenColor "#eeeeee" "#444444" . pad
    , ppUrgent           = dzenColor "#606060" "#ffffff" . pad
    , ppLayout           = \l -> ""
    , ppTitle            = \t -> ""
    , ppOutput           = hPutStrLn h
    }

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = setWMName "LG3D"

myFont = "DejaVu Sans:size=9"
myStatusBar = "sh ~/.statusbar.sh"
myDzenLog = "sleep 2; sh ~/.log.sh"
myTray = "sleep 2; sh ~/.tray.sh"
------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = do
    spawn myStatusBar
    d <- spawnPipe myDzenLog
    spawn myTray
    xmonad $ docks $ ewmh defaultConfig {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = fullscreenEventHook <+> myEventHook,
        logHook            = takeTopFocus <+> myLogHook d,
        startupHook        = myStartupHook
    }
