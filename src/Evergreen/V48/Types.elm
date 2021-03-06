module Evergreen.V48.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Duration
import Email
import Evergreen.V48.Bounds
import Evergreen.V48.Change
import Evergreen.V48.Cursor
import Evergreen.V48.Grid
import Evergreen.V48.Helper
import Evergreen.V48.LocalGrid
import Evergreen.V48.LocalModel
import Evergreen.V48.NotifyMe
import Evergreen.V48.Point2d
import Evergreen.V48.RecentChanges
import Evergreen.V48.Units
import Evergreen.V48.UrlHelper
import Evergreen.V48.User
import EverySet
import Html.Events.Extra.Mouse
import Keyboard
import Lamdera
import List.Nonempty
import Math.Vector2
import Pixels
import Quantity
import SendGrid
import Time
import Url
import WebGL
import WebGL.Texture


type alias FrontendLoading = 
    { key : Browser.Navigation.Key
    , windowSize : (Evergreen.V48.Helper.Coord Pixels.Pixels)
    , devicePixelRatio : (Quantity.Quantity Float (Quantity.Rate Evergreen.V48.Units.WorldPixel Pixels.Pixels))
    , zoomFactor : Int
    , time : Time.Posix
    , viewPoint : (Evergreen.V48.Helper.Coord Evergreen.V48.Units.AsciiUnit)
    , mousePosition : (Evergreen.V48.Point2d.Point2d Pixels.Pixels Evergreen.V48.Units.ScreenCoordinate)
    , showNotifyMe : Bool
    , notifyMeModel : Evergreen.V48.NotifyMe.Model
    }


type MouseButtonState
    = MouseButtonUp 
    { current : (Evergreen.V48.Point2d.Point2d Pixels.Pixels Evergreen.V48.Units.ScreenCoordinate)
    }
    | MouseButtonDown 
    { start : (Evergreen.V48.Point2d.Point2d Pixels.Pixels Evergreen.V48.Units.ScreenCoordinate)
    , start_ : (Evergreen.V48.Point2d.Point2d Evergreen.V48.Units.WorldPixel Evergreen.V48.Units.WorldCoordinate)
    , current : (Evergreen.V48.Point2d.Point2d Pixels.Pixels Evergreen.V48.Units.ScreenCoordinate)
    }


type ToolType
    = DragTool
    | SelectTool
    | HighlightTool (Maybe (Evergreen.V48.User.UserId, (Evergreen.V48.Helper.Coord Evergreen.V48.Units.AsciiUnit)))


type alias FrontendLoaded = 
    { key : Browser.Navigation.Key
    , localModel : (Evergreen.V48.LocalModel.LocalModel Evergreen.V48.Change.Change Evergreen.V48.LocalGrid.LocalGrid)
    , meshes : (Dict.Dict Evergreen.V48.Helper.RawCellCoord (WebGL.Mesh Evergreen.V48.Grid.Vertex))
    , cursorMesh : (WebGL.Mesh 
    { position : Math.Vector2.Vec2
    })
    , viewPoint : (Evergreen.V48.Point2d.Point2d Evergreen.V48.Units.WorldPixel Evergreen.V48.Units.WorldCoordinate)
    , viewPointLastInterval : (Evergreen.V48.Point2d.Point2d Evergreen.V48.Units.WorldPixel Evergreen.V48.Units.WorldCoordinate)
    , cursor : Evergreen.V48.Cursor.Cursor
    , texture : (Maybe WebGL.Texture.Texture)
    , pressedKeys : (List Keyboard.Key)
    , windowSize : (Evergreen.V48.Helper.Coord Pixels.Pixels)
    , devicePixelRatio : (Quantity.Quantity Float (Quantity.Rate Evergreen.V48.Units.WorldPixel Pixels.Pixels))
    , zoomFactor : Int
    , mouseLeft : MouseButtonState
    , lastMouseLeftUp : (Maybe (Time.Posix, (Evergreen.V48.Point2d.Point2d Pixels.Pixels Evergreen.V48.Units.ScreenCoordinate)))
    , mouseMiddle : MouseButtonState
    , pendingChanges : (List Evergreen.V48.Change.LocalChange)
    , tool : ToolType
    , undoAddLast : Time.Posix
    , time : Time.Posix
    , lastTouchMove : (Maybe Time.Posix)
    , userHoverHighlighted : (Maybe Evergreen.V48.User.UserId)
    , highlightContextMenu : (Maybe 
    { userId : Evergreen.V48.User.UserId
    , hidePoint : (Evergreen.V48.Helper.Coord Evergreen.V48.Units.AsciiUnit)
    })
    , adminEnabled : Bool
    , animationElapsedTime : Duration.Duration
    , ignoreNextUrlChanged : Bool
    , showNotifyMe : Bool
    , notifyMeModel : Evergreen.V48.NotifyMe.Model
    }


type FrontendModel
    = Loading FrontendLoading
    | Loaded FrontendLoaded


type alias BackendUserData = 
    { hiddenUsers : (EverySet.EverySet Evergreen.V48.User.UserId)
    , hiddenForAll : Bool
    , undoHistory : (List (Dict.Dict Evergreen.V48.Helper.RawCellCoord Int))
    , redoHistory : (List (Dict.Dict Evergreen.V48.Helper.RawCellCoord Int))
    , undoCurrent : (Dict.Dict Evergreen.V48.Helper.RawCellCoord Int)
    }


type alias SubscribedEmail = 
    { email : Email.Email
    , frequency : Evergreen.V48.NotifyMe.Frequency
    , confirmTime : Time.Posix
    , userId : Evergreen.V48.User.UserId
    , unsubscribeKey : Evergreen.V48.UrlHelper.UnsubscribeEmailKey
    }


type alias PendingEmail = 
    { email : Email.Email
    , frequency : Evergreen.V48.NotifyMe.Frequency
    , creationTime : Time.Posix
    , userId : Evergreen.V48.User.UserId
    , key : Evergreen.V48.UrlHelper.ConfirmEmailKey
    }


type BackendError
    = SendGridError Email.Email SendGrid.Error


type alias BackendModel =
    { grid : Evergreen.V48.Grid.Grid
    , userSessions : (Dict.Dict Lamdera.SessionId 
    { clientIds : (Dict.Dict Lamdera.ClientId (Evergreen.V48.Bounds.Bounds Evergreen.V48.Units.CellUnit))
    , userId : Evergreen.V48.User.UserId
    })
    , users : (Dict.Dict Evergreen.V48.User.RawUserId BackendUserData)
    , usersHiddenRecently : (List 
    { reporter : Evergreen.V48.User.UserId
    , hiddenUser : Evergreen.V48.User.UserId
    , hidePoint : (Evergreen.V48.Helper.Coord Evergreen.V48.Units.AsciiUnit)
    })
    , userChangesRecently : Evergreen.V48.RecentChanges.RecentChanges
    , subscribedEmails : (List SubscribedEmail)
    , pendingEmails : (List PendingEmail)
    , secretLinkCounter : Int
    , errors : (List (Time.Posix, BackendError))
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | NoOpFrontendMsg
    | TextureLoaded (Result WebGL.Texture.Error WebGL.Texture.Texture)
    | KeyMsg Keyboard.Msg
    | KeyDown Keyboard.RawKey
    | WindowResized (Evergreen.V48.Helper.Coord Pixels.Pixels)
    | GotDevicePixelRatio (Quantity.Quantity Float (Quantity.Rate Evergreen.V48.Units.WorldPixel Pixels.Pixels))
    | UserTyped String
    | MouseDown Html.Events.Extra.Mouse.Button (Evergreen.V48.Point2d.Point2d Pixels.Pixels Evergreen.V48.Units.ScreenCoordinate)
    | MouseUp Html.Events.Extra.Mouse.Button (Evergreen.V48.Point2d.Point2d Pixels.Pixels Evergreen.V48.Units.ScreenCoordinate)
    | MouseMove (Evergreen.V48.Point2d.Point2d Pixels.Pixels Evergreen.V48.Units.ScreenCoordinate)
    | TouchMove (Evergreen.V48.Point2d.Point2d Pixels.Pixels Evergreen.V48.Units.ScreenCoordinate)
    | ShortIntervalElapsed Time.Posix
    | VeryShortIntervalElapsed Time.Posix
    | ZoomFactorPressed Int
    | SelectToolPressed ToolType
    | UndoPressed
    | RedoPressed
    | CopyPressed
    | CutPressed
    | UnhideUserPressed Evergreen.V48.User.UserId
    | UserTagMouseEntered Evergreen.V48.User.UserId
    | UserTagMouseExited Evergreen.V48.User.UserId
    | HideForAllTogglePressed Evergreen.V48.User.UserId
    | ToggleAdminEnabledPressed
    | HideUserPressed 
    { userId : Evergreen.V48.User.UserId
    , hidePoint : (Evergreen.V48.Helper.Coord Evergreen.V48.Units.AsciiUnit)
    }
    | AnimationFrame Time.Posix
    | PressedCancelNotifyMe
    | PressedSubmitNotifyMe Evergreen.V48.NotifyMe.Validated
    | NotifyMeModelChanged Evergreen.V48.NotifyMe.Model


type ToBackend
    = RequestData (Evergreen.V48.Bounds.Bounds Evergreen.V48.Units.CellUnit)
    | GridChange (List.Nonempty.Nonempty Evergreen.V48.Change.LocalChange)
    | ChangeViewBounds (Evergreen.V48.Bounds.Bounds Evergreen.V48.Units.CellUnit)
    | NotifyMeSubmitted Evergreen.V48.NotifyMe.Validated
    | ConfirmationEmailConfirmed_ Evergreen.V48.UrlHelper.ConfirmEmailKey
    | UnsubscribeEmail Evergreen.V48.UrlHelper.UnsubscribeEmailKey


type BackendMsg
    = UserDisconnected Lamdera.SessionId Lamdera.ClientId
    | NotifyAdminTimeElapsed Time.Posix
    | NotifyAdminEmailSent
    | ConfirmationEmailSent Lamdera.SessionId Time.Posix (Result SendGrid.Error ())
    | ChangeEmailSent Time.Posix Email.Email (Result SendGrid.Error ())
    | UpdateFromFrontend Lamdera.SessionId Lamdera.ClientId ToBackend Time.Posix


type alias LoadingData_ = 
    { user : Evergreen.V48.User.UserId
    , grid : Evergreen.V48.Grid.Grid
    , hiddenUsers : (EverySet.EverySet Evergreen.V48.User.UserId)
    , adminHiddenUsers : (EverySet.EverySet Evergreen.V48.User.UserId)
    , undoHistory : (List (Dict.Dict Evergreen.V48.Helper.RawCellCoord Int))
    , redoHistory : (List (Dict.Dict Evergreen.V48.Helper.RawCellCoord Int))
    , undoCurrent : (Dict.Dict Evergreen.V48.Helper.RawCellCoord Int)
    , viewBounds : (Evergreen.V48.Bounds.Bounds Evergreen.V48.Units.CellUnit)
    }


type ToFrontend
    = LoadingData LoadingData_
    | ChangeBroadcast (List.Nonempty.Nonempty Evergreen.V48.Change.Change)
    | NotifyMeEmailSent 
    { isSuccessful : Bool
    }
    | NotifyMeConfirmed
    | UnsubscribeEmailConfirmed