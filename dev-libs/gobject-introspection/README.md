The sole reason for keeping this package is to use python3.6. After updating
python3, this could be moved back to portage-stable.

The additional reason is to change the call to the python_gen_cond_dep
function by adding the second parameter (python3_6). I think that
after updating python3 _and_ the python eclasses, this can be reverted
too.

Also replaced PYTHON_MULTI_USEDEP with PYTHON_USEDEP.

Gentoo commit: cd7fea00270ceb0c0cf53ac330c47825f0e7bc5d
