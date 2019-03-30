var gulp         = require("gulp"),
    sass         = require("gulp-sass"),
    autoprefixer = require("gulp-autoprefixer");

var srcp = "themes/janwxyz/src",
    dest = "themes/janwxyz/static";


var compileScss = function () {
    gulp.src(srcp + "/scss/**/*.scss")
        .pipe(sass({
            outputStyle : "compressed",
            precision: 8,
            includePaths: [
                'node_modules/bootstrap/scss',
            ],
        }))
        .pipe(autoprefixer({
            browsers : ["last 20 versions"]
        }))
        .pipe(gulp.dest(dest + "/css"))
}

const compile = gulp.parallel([compileScss, ])
export { compile }



// // Watch asset folder for changes
// gulp.task("watch", ["build"], function () {
//     var watcher = gulp.watch(srcp + "/scss/**/*", ["scss"])
//     watcher.on('error', function() {});
// })

// gulp.task("build", ["scss"])

// Set watch as default task
// gulp.task("default", ["scss"])

