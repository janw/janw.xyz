var gulp         = require("gulp"),
    sass         = require("gulp-sass"),
    autoprefixer = require("gulp-autoprefixer")

gulp.task("scss", function () {
    gulp.src("src/scss/**/*.scss")
        .pipe(sass({
            outputStyle : "compressed",
            precision: 8,
            includePaths: ['node_modules/bootstrap/scss'],
        }))
        .pipe(autoprefixer({
            browsers : ["last 20 versions"]
        }))
        .pipe(gulp.dest("static/css"))
})

// Watch asset folder for changes
gulp.task("watch", ["scss"], function () {
    var watcher = gulp.watch("src/scss/**/*", ["scss"])
    watcher.on('error', function() {});
})

// Set watch as default task
gulp.task("default", ["watch"])
