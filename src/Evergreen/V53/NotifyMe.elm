module Evergreen.V53.NotifyMe exposing (..)

import Evergreen.V53.Email exposing (Email)


type Status
    = Form
    | FormWithError
    | SendingToBackend
    | WaitingOnConfirmation


type Frequency
    = Every3Hours
    | Every12Hours
    | Daily
    | Weekly
    | Monthly


type alias InProgressModel =
    { status : Status
    , email : String
    , frequency : Maybe Frequency
    }


type Model
    = InProgress InProgressModel
    | Completed
    | BackendError
    | Unsubscribing
    | Unsubscribed


type ThreeHours
    = ThreeHours Never


type alias Validated =
    { email : Email
    , frequency : Frequency
    }
