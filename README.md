# Tim’s site

This is my personal home page, implemented as a [Hanami][hanami] app extended to produce static
content for deployment.

[hanami]: http://hanamirb.org

## Getting started

Run `./bin/setup` to set up the application.

Review `.env` and adjust the settings as required.

## Building the site

Run `./bin/build` to build the site. This will empty the `build/` directory and then repopulate it
with a new copy of the site's files.

## Rationale

I wanted a static site generator that would allow me to work in the same way I do when building a
typical server-side web application. So rather than building within the confines of a static site
generation framework, I wanted an ordinary Ruby app app that just so happens to export a static site
as part of its behavior.

This means:

- A standard, extensible application structure, provided here by [Hanami][hanami].
- A focus on data and types
- A distinct layer for with working with persisted data
- And a fully-fleshed view layer (with proper encapsulation of view behaviour, no helpers!)

## Structure

This is a typical Hanami app, with a couple of additions:

- An in-memory SQLite database, populated from the static files in `source/` by `Site::Prepare`
- An extension to the router that captures GET routes
- A `Site::Generate` that uses these routes and their matching actions to output static content
- An `#each` method on dynamic actions that outputs their possible slugs, used by the above
- All tied together by a `bin/build` script that is run on deploy to create the static site

## License

All code is MIT licensed. All site content (in `app/assets/` and `source/`) is copyright Tim Riley,
all rights reserved.
