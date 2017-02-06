.PHONY: clean
clean:
	rm -f *.out *.err core.*

%:
	bsub -J $@ -o "$@-%J.out" -e "$@-%J.err" -q "big-multi" -n 8 ./test-$@.sh
