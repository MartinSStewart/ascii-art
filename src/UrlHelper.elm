module UrlHelper exposing (ConfirmEmailKey(..), InternalRoute(..), coordQueryParser, encodeUrl, internalRoute, notifyMe, urlParser)

import Helper exposing (Coord)
import Units exposing (AsciiUnit)
import Url.Builder
import Url.Parser exposing ((</>), (<?>))
import Url.Parser.Query


coordQueryParser : Url.Parser.Query.Parser (Coord AsciiUnit)
coordQueryParser =
    Url.Parser.Query.map2
        (\maybeX maybeY ->
            ( Maybe.withDefault 0 maybeX, Maybe.withDefault 0 maybeY ) |> Helper.fromRawCoord
        )
        (Url.Parser.Query.int "x")
        (Url.Parser.Query.int "y")


urlParser : Url.Parser.Parser (InternalRoute -> b) b
urlParser =
    Url.Parser.oneOf
        [ Url.Parser.top
            <?> coordQueryParser
            |> Url.Parser.map (internalRoute False)
        , Url.Parser.s notifyMe
            <?> coordQueryParser
            |> Url.Parser.map (internalRoute True)
        , Url.Parser.s notifyMeConfirmation </> Url.Parser.string |> Url.Parser.map EmailConfirmationRoute
        ]


encodeUrl : InternalRoute -> String
encodeUrl route =
    case route of
        InternalRoute internalRoute_ ->
            let
                ( x, y ) =
                    Helper.toRawCoord internalRoute_.viewPoint
            in
            Url.Builder.relative
                (if internalRoute_.showNotifyMe then
                    [ notifyMe ]

                 else
                    [ "/" ]
                )
                [ Url.Builder.int "x" x, Url.Builder.int "y" y ]

        EmailConfirmationRoute key ->
            Url.Builder.relative [ notifyMeConfirmation, key ] []


notifyMe : String
notifyMe =
    "notify-me"


notifyMeConfirmation : String
notifyMeConfirmation =
    "a"


type InternalRoute
    = InternalRoute { showNotifyMe : Bool, viewPoint : Coord AsciiUnit }
    | EmailConfirmationRoute ConfirmEmailKey


type ConfirmEmailKey
    = ConfirmEmailKey String


internalRoute : Bool -> Coord AsciiUnit -> InternalRoute
internalRoute showNotifyMe viewPoint =
    InternalRoute { showNotifyMe = showNotifyMe, viewPoint = viewPoint }
