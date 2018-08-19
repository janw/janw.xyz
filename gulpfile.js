var gulp         = require("gulp"),
    sass         = require("gulp-sass"),
    autoprefixer = require("gulp-autoprefixer");

var srcp = "themes/janwxyz/src",
    dest = "themes/janwxyz/static";

var fa_webfonts = 'node_modules/@fortawesome/fontawesome-pro/webfonts/*'

gulp.task("fa-fonts", function() {
    gulp.src(fa_webfonts)
        .pipe(gulp.dest(dest + "/fonts"))
})

gulp.task("scss", function () {
    gulp.src(srcp + "/scss/**/*.scss")
        .pipe(sass({
            outputStyle : "compressed",
            precision: 8,
            includePaths: [
                'node_modules/bootstrap/scss',
                'node_modules/@fortawesome/fontawesome-pro/scss'
            ],
        }))
        .pipe(autoprefixer({
            browsers : ["last 20 versions"]
        }))
        .pipe(gulp.dest(dest + "/css"))
})

// Watch asset folder for changes
gulp.task("watch", ["build"], function () {
    var watcher = gulp.watch(srcp + "/scss/**/*", ["scss"])
    watcher.on('error', function() {});
})

gulp.task("build", ["scss", "fa-fonts"])

// Set watch as default task
gulp.task("default", ["watch"])

