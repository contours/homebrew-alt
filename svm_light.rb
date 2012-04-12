require 'formula'

class SvmLight < Formula
  url 'http://osmot.cs.cornell.edu/svm_light/v6.02/svm_light.tar.gz'
  version '6.02'
  homepage 'http://svmlight.joachims.org/'
  md5 '59768adde96737b1ecef123bc3a612ce'

  def patches
    DATA
  end

  def install
    system "make"
    bin.install ['svm_learn', 'svm_classify', 'svm_classifyd']
  end
end

__END__
diff --git a/Makefile b/Makefile
index 8b5e19a..075e017 100755
--- a/Makefile
+++ b/Makefile
@@ -26,6 +26,7 @@ tidy:
 clean:	tidy
 	rm -f svm_learn
 	rm -f svm_classify
+	rm -f svm_classifyd
 	rm -f libsvmlight.so
 
 help:   info
@@ -61,8 +62,9 @@ svm_learn_hideo: svm_learn_main.o svm_learn.o svm_common.o svm_hideo.o
 #svm_learn_loqo: svm_learn_main.o svm_learn.o svm_common.o svm_loqo.o loqo
 #	$(LD) $(LFLAGS) svm_learn_main.o svm_learn.o svm_common.o svm_loqo.o pr_loqo/pr_loqo.o -o svm_learn $(LIBS)
 
-svm_classify: svm_classify.o svm_common.o 
+svm_classify: svm_classify.o svm_classifyd.o svm_common.o 
 	$(LD) $(LFLAGS) svm_classify.o svm_common.o -o svm_classify $(LIBS)
+	$(LD) $(LFLAGS) svm_classifyd.o svm_common.o -o svm_classifyd $(LIBS)
 
 
 # Create library libsvmlight.so, so that external code can get access to the
@@ -98,6 +100,9 @@ svm_learn_main.o: svm_learn_main.c svm_learn.h svm_common.h
 svm_classify.o: svm_classify.c svm_common.h kernel.h
 	$(CC) -c $(CFLAGS) svm_classify.c -o svm_classify.o
 
+svm_classifyd.o: svm_classifyd.c svm_common.h kernel.h
+	$(CC) -c $(CFLAGS) svm_classifyd.c -o svm_classifyd.o
+
 #loqo: pr_loqo/pr_loqo.o
 
 #pr_loqo/pr_loqo.o: pr_loqo/pr_loqo.c
diff --git a/svm_classifyd.c b/svm_classifyd.c
new file mode 100755
index 0000000..bb217e4
--- /dev/null
+++ b/svm_classifyd.c
@@ -0,0 +1,66 @@
+#include "svm_common.h"
+
+char modelfile[200];
+
+int main (int argc, char* argv[]) {
+
+  MODEL *model; 
+  WORD *words;
+  char *line = NULL;
+  size_t len = 0;
+  ssize_t read;
+  double dist, doc_label, costfactor;
+  long queryid, slackid, wnum, i;
+  char *comment; 
+  DOC *doc;
+
+  if (argc < 2) {
+    printf("usage: svm_classify model_file\n");
+    exit(0);
+  }
+  strcpy (modelfile, argv[1]);
+
+  model = read_model(modelfile);
+  words = (WORD *) malloc(sizeof(WORD) * model->totwords);
+
+  if (model->kernel_parm.kernel_type == 0) { // linear kernel
+    // compute weight vector
+    add_weight_vector_to_linear_model(model);
+  }
+
+  while (1) {
+    read = getline(&line, &len, stdin);
+    if (read == -1) { continue; }
+
+    parse_document(line, words, &doc_label, &queryid, &slackid, 
+                   &costfactor, &wnum, model->totwords, &comment);
+
+    if (model->kernel_parm.kernel_type == 0) { // linear kernel
+      // make sure features correspond to model
+      for (i = 0; (words[i]).wnum != 0; i++) {
+        if ((words[i]).wnum > model->totwords) {
+          printf("unrecognized feature (feature number is too high)\n");
+          exit(1);
+        }
+      }
+    }                                
+    
+    doc = create_example(-1, 0, 0, 0.0, create_svector(words, comment, 1.0));
+
+    if (model->kernel_parm.kernel_type == 0) { // linear kernel    
+      dist = classify_example_linear(model, doc); 
+    } else {
+      dist = classify_example(model, doc);
+    }
+
+    printf("%.8g\n",dist);
+
+    free_example(doc, 1);
+  }
+}
+
+
+
+
+
+
-- 
1.7.9.5


