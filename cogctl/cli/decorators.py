import click
import requests
from functools import update_wrapper
from cogctl.exceptions import CogctlAPICredentialsException


def error_handler(f):
    """
    Decorator used for commands to centralize error handling.
    """
    def wrapped(*args, **kwargs):
        try:
            return f(*args, **kwargs)

        except CogctlAPICredentialsException:
            raise click.ClickException(
                "Must set URL, user, and password to make API calls")

        except requests.exceptions.ConnectionError as err:
            url = err.request.url
            raise click.ClickException(
                "Could not establish HTTP connection to {}. "
                "Please check your host, user, and password "
                "settings.".format(url))

        except requests.exceptions.HTTPError as err:
            resp = err.response
            json = resp.json()

            # This is what currently comes back when trying to delete
            # a relay group that has members or assigned bundles.
            #
            # If a relay group has both members and assigned bundles,
            # only the assigned bundles error message is present
            # (since that's what the server checks first).
            if (resp.status_code == 422 and
                    "errors" in json and
                    "id" in json["errors"]):
                raise click.ClickException(" ".join(json["errors"]["id"]))

            # The chat handle errors are kind of messy right now. When
            # trying to set a chat handle that doesn't even exist in
            # your chat provider, we return {"errors": "User with
            # handle '$HANDLE' not found"}. When another user has
            # already claimed the handle, "errors" is a list of
            # strings.
            #
            # :(
            if (resp.status_code == 422 and
                    "errors" in json and
                    "handle" in json["errors"]):
                if type(json["errors"]) == dict:
                    raise click.ClickException(" ".join(json["errors"]["handle"]))
                else:
                    raise click.ClickException(json["errors"])

            errors = json["errors"]
            if type(errors) == list:
                raise click.ClickException(" ".join(json["errors"]))
            else:
                raise click.ClickException(errors)

    return update_wrapper(wrapped, f)
