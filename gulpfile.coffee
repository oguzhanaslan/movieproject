gulp        = require('gulp')
uglify      = require('gulp-uglify')
source      = require('vinyl-source-stream')
watchify    = require('watchify')
reactify    = require('reactify')
streamify   = require('gulp-streamify')
browserify  = require('browserify')
htmlreplace = require('gulp-html-replace')

path =
  HTML         : 'index.html',
  MINIFIED_OUT : 'build.min.js',
  OUT          : 'build.js',
  DEST         : 'dist',
  DEST_BUILD   : 'dist/build',
  DEST_SRC     : 'dist/src'
  ENTRY_POINT  : 'client/app/lib/App.js'


gulp.task 'copy', ->
  gulp.src(path.HTML)
    .pipe(gulp.dest(path.DEST))


gulp.task 'watch', ->
  gulp.watch path.HTML, ['copy']
  watcher = watchify(browserify({
    entries      : [path.ENTRY_POINT]
    transform    : [reactify]
    debug        : true
    cache        : {}
    packageCache : {}
    fullPaths    : true
  }))

  return watcher.on('update', ->
    watcher.bundle()
      .pipe(source(path.OUT))
      .pipe(gulp.dest(path.DEST_SRC))
      console.log('Updated')
  )
    .bundle()
    .pipe(source(path.OUT))
    .pipe(gulp.dest(path.DEST_SRC))


gulp.task 'build', ->
  browserify({
    entries: [path.ENTRY_POINT],
    transform: [reactify],
  })
    .bundle()
    .pipe(source(path.MINIFIED_OUT))
    .pipe(streamify(uglify(path.MINIFIED_OUT)))
    .pipe(gulp.dest(path.DEST_BUILD))


gulp.task 'replaceHTML', ->
  gulp.src(path.HTML)
    .pipe(htmlreplace({
      'js': 'build/' + path.MINIFIED_OUT
    }))
    .pipe(gulp.dest(path.DEST))


gulp.task('production', ['replaceHTML', 'build'])

gulp.task 'default', ['watch']
