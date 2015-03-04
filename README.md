This is a [Homebrew](http://brew.sh/) recipe for installing
[svmlight](http://svmlight.joachims.org/). It include a patch that
adds a binary called `svm_classifyd`. This is basically a classifier
which can run as a daemon and be communicated with over stdin/stdout,
to avoid having to spawn new `svm_classify` processes.

This is used by
[`node-splitta`](https://github.com/contours/node-splitta).
