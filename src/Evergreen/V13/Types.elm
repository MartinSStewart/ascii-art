module Evergreen.V13.Types exposing (..)

import Evergreen.V13.Bounds
import Browser
import Browser.Navigation
import Evergreen.V13.Change
import Evergreen.V13.Cursor
import Dict
import EverySet
import Evergreen.V13.Grid
import Evergreen.V13.Helper
import Html.Events.Extra.Mouse
import Keyboard
import List.Nonempty
import Evergreen.V13.LocalGrid
import Evergreen.V13.LocalModel
import Math.Vector2
import Pixels
import Evergreen.V13.Point2d
import Quantity
import Time
import Evergreen.V13.Units
import Url
import Evergreen.V13.User
import WebGL
import WebGL.Texture


type alias FrontendLoading = 
    { key : Browser.Navigation.Key
    , windowSize : (Evergreen.V13.Helper.Coord Pixels.Pixels)
    , devicePixelRatio : (Quantity.Quantity Float (Quantity.Rate Evergreen.V13.Units.WorldPixel Pixels.Pixels))
    , zoomFactor : Int
    , time : Time.Posix
    , viewPoint : (Evergreen.V13.Helper.Coord Evergreen.V13.Units.AsciiUnit)
    }


type MouseButtonState
    = MouseButtonUp
    | MouseButtonDown 
    { start : (Evergreen.V13.Point2d.Point2d Pixels.Pixels Evergreen.V13.Units.ScreenCoordinate)
    , start_ : (Evergreen.V13.Point2d.Point2d Evergreen.V13.Units.WorldPixel Evergreen.V13.Units.WorldCoordinate)
    , current : (Evergreen.V13.Point2d.Point2d Pixels.Pixels Evergreen.V13.Units.ScreenCoordinate)
    }


type ToolType
    = DragTool
    | SelectTool
    | HideUserTool (Maybe (Evergreen.V13.User.UserId, (Evergreen.V13.Helper.Coord Evergreen.V13.Units.AsciiUnit)))


type alias FrontendLoaded = 
    { key : Browser.Navigation.Key
    , localModel : (Evergreen.V13.LocalModel.LocalModel Evergreen.V13.Change.Change Evergreen.V13.LocalGrid.LocalGrid)
    , meshes : (Dict.Dict Evergreen.V13.Helper.RawCellCoord (WebGL.Mesh Evergreen.V13.Grid.Vertex))
    , cursorMesh : (WebGL.Mesh 
    { position : Math.Vector2.Vec2
    })
    , viewPoint : (Evergreen.V13.Point2d.Point2d Evergreen.V13.Units.WorldPixel Evergreen.V13.Units.WorldCoordinate)
    , viewPointLastInterval : (Evergreen.V13.Point2d.Point2d Evergreen.V13.Units.WorldPixel Evergreen.V13.Units.WorldCoordinate)
    , cursor : Evergreen.V13.Cursor.Cursor
    , texture : (Maybe WebGL.Texture.Texture)
    , pressedKeys : (List Keyboard.Key)
    , windowSize : (Evergreen.V13.Helper.Coord Pixels.Pixels)
    , devicePixelRatio : (Quantity.Quantity Float (Quantity.Rate Evergreen.V13.Units.WorldPixel Pixels.Pixels))
    , zoomFactor : Int
    , mouseLeft : MouseButtonState
    , mouseMiddle : MouseButtonState
    , pendingChanges : (List Evergreen.V13.Change.LocalChange)
    , tool : ToolType
    , undoAddLast : Time.Posix
    , time : Time.Posix
    , lastTouchMove : (Maybe Time.Posix)
    , userPressHighlighted : (Maybe Evergreen.V13.User.UserId)
    , userHoverHighlighted : (Maybe Evergreen.V13.User.UserId)
    , adminEnabled : Bool
    }


type FrontendModel
    = Loading FrontendLoading
    | Loaded FrontendLoaded


type alias SessionId = String


type alias ClientId = String


type alias BackendUserData = 
    { userData : Evergreen.V13.User.UserData
    , hiddenUsers : (EverySet.EverySet Evergreen.V13.User.UserId)
    , hiddenForAll : Bool
    , undoHistory : (List (Dict.Dict Evergreen.V13.Helper.RawCellCoord Int))
    , redoHistory : (List (Dict.Dict Evergreen.V13.Helper.RawCellCoord Int))
    , undoCurrent : (Dict.Dict Evergreen.V13.Helper.RawCellCoord Int)
    }


type alias BackendModel =
    { grid : Evergreen.V13.Grid.Grid
    , userSessions : (Dict.Dict SessionId 
    { clientIds : (Dict.Dict ClientId (Evergreen.V13.Bounds.Bounds Evergreen.V13.Units.CellUnit))
    , userId : Evergreen.V13.User.UserId
    })
    , users : (Dict.Dict Evergreen.V13.User.RawUserId BackendUserData)
    , usersHiddenRecently : (List 
    { reporter : Evergreen.V13.User.UserId
    , hiddenUser : Evergreen.V13.User.UserId
    , hidePoint : (Evergreen.V13.Helper.Coord Evergreen.V13.Units.AsciiUnit)
    })
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | NoOpFrontendMsg
    | TextureLoaded (Result WebGL.Texture.Error WebGL.Texture.Texture)
    | KeyMsg Keyboard.Msg
    | KeyDown Keyboard.RawKey
    | WindowResized (Evergreen.V13.Helper.Coord Pixels.Pixels)
    | GotDevicePixelRatio (Quantity.Quantity Float (Quantity.Rate Evergreen.V13.Units.WorldPixel Pixels.Pixels))
    | UserTyped String
    | MouseDown Html.Events.Extra.Mouse.Button (Evergreen.V13.Point2d.Point2d Pixels.Pixels Evergreen.V13.Units.ScreenCoordinate)
    | MouseUp Html.Events.Extra.Mouse.Button (Evergreen.V13.Point2d.Point2d Pixels.Pixels Evergreen.V13.Units.ScreenCoordinate)
    | MouseMove (Evergreen.V13.Point2d.Point2d Pixels.Pixels Evergreen.V13.Units.ScreenCoordinate)
    | TouchMove (Evergreen.V13.Point2d.Point2d Pixels.Pixels Evergreen.V13.Units.ScreenCoordinate)
    | ShortIntervalElapsed Time.Posix
    | VeryShortIntervalElapsed Time.Posix
    | ZoomFactorPressed Int
    | SelectToolPressed ToolType
    | UndoPressed
    | RedoPressed
    | CopyPressed
    | CutPressed
    | UnhideUserPressed Evergreen.V13.User.UserId
    | UserColorSquarePressed Evergreen.V13.User.UserId
    | UserTagMouseEntered Evergreen.V13.User.UserId
    | UserTagMouseExited Evergreen.V13.User.UserId
    | HideForAllTogglePressed Evergreen.V13.User.UserId
    | ToggleAdminEnabledPressed


type ToBackend
    = RequestData (Evergreen.V13.Bounds.Bounds Evergreen.V13.Units.CellUnit)
    | GridChange (List.Nonempty.Nonempty Evergreen.V13.Change.LocalChange)
    | ChangeViewBounds (Evergreen.V13.Bounds.Bounds Evergreen.V13.Units.CellUnit)


type BackendMsg
    = UserDisconnected SessionId ClientId
    | NotifyAdminTimeElapsed Time.Posix
    | NotifyAdminEmailSent


type alias LoadingData_ = 
    { user : (Evergreen.V13.User.UserId, Evergreen.V13.User.UserData)
    , grid : Evergreen.V13.Grid.Grid
    , otherUsers : (List (Evergreen.V13.User.UserId, Evergreen.V13.User.UserData))
    , hiddenUsers : (EverySet.EverySet Evergreen.V13.User.UserId)
    , adminHiddenUsers : (EverySet.EverySet Evergreen.V13.User.UserId)
    , undoHistory : (List (Dict.Dict Evergreen.V13.Helper.RawCellCoord Int))
    , redoHistory : (List (Dict.Dict Evergreen.V13.Helper.RawCellCoord Int))
    , undoCurrent : (Dict.Dict Evergreen.V13.Helper.RawCellCoord Int)
    , viewBounds : (Evergreen.V13.Bounds.Bounds Evergreen.V13.Units.CellUnit)
    }


type ToFrontend
    = LoadingData LoadingData_
    | ChangeBroadcast (List.Nonempty.Nonempty Evergreen.V13.Change.Change)