gulp = require 'gulp'
coffee = require 'gulp-coffee'
cache = require 'gulp-cached'
config = require './build-configuration'
compass = require 'gulp-compass'
nodemon = require 'gulp-nodemon'
plumber = require 'gulp-plumber'
clean = require 'gulp-clean'
livereload = require 'gulp-livereload'
cleaning = require 'gulp-initial-cleaning'
symlink = require 'gulp-symlink'
templateCache = require 'gulp-angular-templatecache'
inject = require 'gulp-inject'


fs = require 'fs'

cleaning({tasks: ['default', 'look'], folders: ['dist/']})

# Define files src
srcCoffee = "#{config.src}/**/*.coffee"
srcCompass = "#{config.src}/**/*.scss"

srcHTML = ["#{config.src}/**/*.html", "!#{config.src}/**/tpl-*.html"]
dist = config.dist


# Coffee
gulp.task 'coffee', ->
  gulp.src(srcCoffee)
    .pipe(cache('coffee'))
    .pipe(plumber())
    .pipe(coffee())
    .pipe(gulp.dest(dist))

# HTML
gulp.task 'html', ['coffee', 'template'], ->
  for module in config.modules
    gulp.src("#{config.srcPublic}/#{module}/index.html")
      .pipe(cache('html'))
      .pipe(inject(gulp.src(config.publicjs, read: false), ignorePath: config.distPublic))
      .pipe(gulp.dest(config.distPublic + module))

# Compass
gulp.task 'compass', ->
  gulp.src(srcCompass)
    .pipe(compass({
      css: config.compass.css
      sass: config.compass.sass
      image: config.compass.sassImg
    }))

# Symlink
gulp.task 'components', ->
  gulp.src(config.components, read:false)
    .pipe(symlink(config.distPublic))

# Template
gulp.task 'template', ->
  for module in config.modules
    gulp.src("#{config.srcPublic}/#{module}/**/tpl-*.html")
      .pipe(templateCache(module: module))
      .pipe(gulp.dest(config.distPublic + module + '/'))

gulp.task 'default', ['template','components','coffee', 'compass', 'html']

# Watch
server = null
gulp.task 'look', ['default'], ->

  # Livereload
  server = livereload()
  gulp.watch(config.livereload).on 'change', (file) ->
    server.changed(file.path);

  # Nodemon
  nodemon(
    script: config.nodemon.server
    ignore: config.nodemon.ignore
  ).on 'restart', ->
    if server then setTimeout ->
      server?.changed('tmp.js')
    , 1000

  gulp.watch srcCoffee, ['coffee']
  gulp.watch "src/**/*.html", ['html']
  gulp.watch srcCompass, ['compass']
