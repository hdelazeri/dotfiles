-- Base
import XMonad
import System.IO (hPutStrLn)
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W

-- Actions
import XMonad.Actions.CopyWindow (kill1)
import XMonad.Actions.MouseResize
import XMonad.Actions.Volume
import XMonad.Actions.WithAll (killAll)

-- Data
import Data.Maybe (fromJust)
import Data.Monoid
import qualified Data.Map as M

-- Hooks
import XMonad.Hooks.DynamicLog (PP (..), dynamicLogWithPP, shorten, wrap, xmobarColor, xmobarPP)
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks (ToggleStruts (ToggleStruts), avoidStruts, docksEventHook, manageDocks)
import XMonad.Hooks.SetWMName

-- Layouts
import XMonad.Layout.SimplestFloat
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed

-- Layout Modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows)
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle (EOT (EOT), mkToggle, (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers (NBFULL, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowArranger (windowArrange)
import XMonad.Layout.WindowNavigation
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts)
import qualified XMonad.Layout.MultiToggle as MT

-- Utilities
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.SpawnOnce

-- Color Scheme
import Colors.DoomOne

myModMask :: KeyMask
myModMask = mod4Mask

myTerminal :: String
myTerminal = "alacritty"

myBrowser :: String
myBrowser = "firefox-developer-edition"

myEmacs :: String
myEmacs = "emacsclient -c -a 'emacs'"

myEditor :: String
myEditor = myEmacs

myBorderWidth :: Dimension
myBorderWidth = 2

myFont :: String
myFont = "xft:SauceCodePro Nerd Font Mono:regular:size=9:antialias=true:hinting=true"

myNormColor :: String
myNormColor = colorBack

myFocusColor :: String
myFocusColor = color15

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myStartupHook :: X ()
myStartupHook = do
  spawn "killall trayer"
  spawnOnce "lxsession"
  spawnOnce "picom --backend glx --vsync"
  spawnOnce "nm-applet"
  spawnOnce "volumeicon"
  spawnOnce "emacs --daemon"
  spawnOnce "dunst"
  spawn ("sleep 2 && trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 0 --transparent true --alpha 0 " ++ colorTrayer ++ " --height 22")
  spawnOnce "nitrogen --restore"
  setWMName "LG3D"

mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

myTabTheme =
  def
    { fontName = myFont,
      activeColor = color15,
      inactiveColor = color08,
      activeBorderColor = color15,
      inactiveBorderColor = colorBack,
      activeTextColor = colorBack,
      inactiveTextColor = color16
    }

tall =
  renamed [Replace "tall"] $
    smartBorders $
      windowNavigation $
        addTabs shrinkText myTabTheme $
          subLayout [] (smartBorders Simplest) $
            limitWindows 12 $
              mySpacing 8 $
                ResizableTall 1 (3 / 100) (1 / 2) []

magnify =
  renamed [Replace "magnify"] $
    smartBorders $
      windowNavigation $
        addTabs shrinkText myTabTheme $
          subLayout [] (smartBorders Simplest) $
            magnifier $
              limitWindows 12 $
                mySpacing 8 $
                  ResizableTall 1 (3 / 100) (1 / 2) []

monocle =
  renamed [Replace "monocle"] $
    smartBorders $
      windowNavigation $
        addTabs shrinkText myTabTheme $
          subLayout [] (smartBorders Simplest) $
            limitWindows 20 Full

floats =
  renamed [Replace "floats"] $
    smartBorders $
      limitWindows 20 simplestFloat

myShowWNameTheme :: SWNConfig
myShowWNameTheme =
  def
    { swn_font = "xft:Ubuntu:bold:size=60",
      swn_fade = 1.0,
      swn_bgcolor = color01,
      swn_color = color16
    }

myLayoutHook =
  avoidStruts $
    mouseResize $
      windowArrange $
        T.toggleLayouts floats $
          mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
  where
    myDefaultLayout =
      withBorder myBorderWidth tall
        ||| magnify
        ||| noBorders monocle

myWorkspaces = [" dev ", " www ", " sys ", " doc ", " vbox ", " chat ", " mus ", " vid ", " gfx "]

myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1 ..] -- (,) == \x y -> (x,y)

clickable ws = "<action=xdotool key super" ++ show i ++ ">" ++ ws ++ "</action>"
  where
    i = fromJust $ M.lookup ws myWorkspaceIndices

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook =
  composeAll
    [ className =? "confirm" --> doFloat,
      className =? "file_progress" --> doFloat
    ]

myKeys :: [(String, X ())]
myKeys =
    -- System
  [ ("M-C-r", spawn "xmonad --recompile"),
    ("M-S-r", spawn "xmonad --restart"),
    ("M-S-q", io exitSuccess),

    -- Run Prompt
    ("M-S-<Return>", spawn ("dmenu_run -i -p \"Run: \" -nb '" ++ colorBack ++ "' -nf '" ++ colorFore ++ "' -sb '" ++ color05 ++ "' -sf '" ++ color01 ++ "' -l 10")),

    -- Usefull programs
    ("M-<Return>", spawn (myTerminal)),
    ("M-b", spawn (myBrowser)),

    -- Kill windows
    ("M-S-c", kill1),
    ("M-S-a", killAll),

    -- Window navigation
    ("M-j", windows W.focusDown),
    ("M-k", windows W.focusUp),
    ("M-m", windows W.focusMaster),

    -- Layouts
    ("M-<Tab>", sendMessage NextLayout),
    ("M-<Space>", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts),

    -- Emacs
    ("M-e e", spawn (myEmacs)),

    -- Media Control
    ("<XF86AudioMute>", toggleMute >> return ()),
    ("<XF86AudioLowerVolume>", lowerVolume 4 >> return ()),
    ("<XF86AudioRaiseVolume>", raiseVolume 4 >> return ())
  ]

main :: IO ()
main = do
  xmproc <- spawnPipe ("xmobar -x 0 $HOME/.config/xmobar/" ++ colorScheme ++ "-xmobarrc")
  xmonad $
    ewmh
      def
        { manageHook = myManageHook <+> manageDocks,
          handleEventHook = docksEventHook,
          modMask = myModMask,
          terminal = myTerminal,
          startupHook = myStartupHook,
          layoutHook = showWName' myShowWNameTheme $ myLayoutHook,
          workspaces = myWorkspaces,
          borderWidth = myBorderWidth,
          normalBorderColor = myNormColor,
          focusedBorderColor = myFocusColor,
          logHook =
            dynamicLogWithPP $
              xmobarPP
                { ppOutput = hPutStrLn xmproc,
                  ppCurrent = xmobarColor color06 "" . wrap ("<box type=Bottom width=2 mb=2 color=" ++ color06 ++ ">") "</box>",
                  ppVisible = xmobarColor color06 "" . clickable,
                  ppHidden = xmobarColor color05 "" . wrap ("<box type=Top width=2 mt=2 color=" ++ color05 ++ ">") "</box>" . clickable,
                  ppHiddenNoWindows = xmobarColor color05 "" . clickable,
                  ppTitle = xmobarColor color16 "" . shorten 60,
                  ppSep = "<fc=" ++ color09 ++ "> <fn=1>|</fn> </fc>",
                  ppUrgent = xmobarColor color02 "" . wrap "!" "!",
                  ppExtras = [windowCount],
                  ppOrder = \(ws : l : t : ex) -> [ws, l] ++ ex ++ [t]
                }
        }
      `additionalKeysP` myKeys
