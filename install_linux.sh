#!/usr/bin/env bash

# Set up the environment variables
mkdir -p $GITHUB_WORKSPACE/cutest
export ARCHDEFS=$GITHUB_WORKSPACE/cutest/archdefs
export SIFDECODE=$GITHUB_WORKSPACE/cutest/sifdecode
export CUTEST=$GITHUB_WORKSPACE/cutest/cutest
export MASTSIF=$GITHUB_WORKSPACE/cutest/mastsif
export MYARCH=pc64.lnx.gfo

# Set top-level directory
TOPDIR=$PWD

# Download the source files
echo ' Downloading source files...'
git config --global advice.detachedHead false
git clone -q -b v2.0.4 --depth 1 https://github.com/ralna/ARCHDefs $ARCHDEFS &
git clone -q -b v2.0.3 --depth 1 https://github.com/ralna/SIFDecode $SIFDECODE &
git clone -q -b v2.0.3 --depth 1 https://github.com/ralna/CUTEst $CUTEST &
git clone -q -b v0.5 --depth 1 https://bitbucket.org/optrove/sif $MASTSIF &
wait

# Set architecture/compiler
source $ARCHDEFS/system.lnx
source $ARCHDEFS/ccompiler.pc64.lnx.gcc
source $ARCHDEFS/compiler.$MYARCH

# Install sifdecode
echo ' Installing SIFDecode...'
cd $SIFDECODE || exit 1

# create architecture-dependent object and module directories
OBJDIR=$SIFDECODE/objects/$MYARCH
MODDIR=$SIFDECODE/modules/$MYARCH
echo "$MACHINE ($OPSYS) $COMPUSED" > $SIFDECODE/versions/$MYARCH
if [[ ! -e $OBJDIR ]]; then
    $MKDIR $OBJDIR
    $MKDIR $OBJDIR/double $OBJDIR/single
else
    [[ ! -e $OBJDIR/double ]] && $MKDIR $OBJDIR/double
    [[ ! -e $OBJDIR/single ]] && $MKDIR $OBJDIR/single
fi
if [[ ! -e $MODDIR ]]; then
    $MKDIR $MODDIR
    $MKDIR $MODDIR/double $MODDIR/single
else
    [[ ! -e $MODDIR/double ]] && $MKDIR $MODDIR/double
    [[ ! -e $MODDIR/single ]] && $MKDIR $MODDIR/single
fi

# Write out the sifdecode/bin/sys file for this architecture
FFLAGS="$LIBCMD"' '`eval echo $MODCMD`' '"$F90"
{
    echo 'RM="'$RM'"'
    echo 'MAKE="'$MAKE'"'
    echo 'CAT="'$CAT'"'
    echo 'SED="'$SED'"'
    echo 'MV="'$MV'"'
    echo 'LS="'$LS'"'
    echo 'LN="'$LN'"'
    echo 'GREP="'$GREP'"'
    echo 'AWK="'$AWK'"'
    echo 'HEAD="'$HEAD'"'
    echo 'TAIL="'$TAIL'"'
    echo 'FORTRAN="'$FORTRAN'"'
    echo 'FFLAGS="'$FFLAGS' '$OPENMP'"'
    echo 'PROBFLAGS="'$FFLAGS' '$BASIC' '$OPTIMIZATION' '$F77' "'
    echo 'BLAS="'$BLAS'"'
    echo 'LAPACK="'$LAPACK'"'
} > $SIFDECODE/bin/sys/$MYARCH

#  write out the sifdecode/makefile/ file for this architecture
MODTMP="$LIBCMD"' '`echo $MODCMD | $SED 's/MOD/(MOD)/g'`
{
    echo ' '
    echo '#  Architecture dependent makefile'
    echo '#  (automatically generated by install_sifdecode)'
    echo ' '
    echo 'VERSION = '$MYARCH
    echo ' '
    echo '#  Basic system commands'
    echo ' '
    echo 'CP = '$CP
    echo 'MV = '$MV
    echo 'RM = '$RM
    echo 'SED = '$SED
    echo 'GREP = '$GREP
    echo 'AR = '$AR
    echo 'ARREPFLAGS = '$ARREPFLAGS
    echo 'RANLIB = '$RANLIB
    echo ' '
    echo '#  Directory for binaries'
    echo ' '
    echo 'PRECIS = double'
    echo 'OBJ = $(SIFDECODE)/objects/$(VERSION)/$(PRECIS)'
    echo 'OBJS = $(SIFDECODE)/objects/$(VERSION)/single'
    echo 'OBJD = $(SIFDECODE)/objects/$(VERSION)/double'
    echo 'MOD = $(SIFDECODE)/modules/$(VERSION)/$(PRECIS)'
    echo 'SEDS = $(SIFDECODE)/seds/$(PRECIS).sed'
    echo 'MVMODS = '"$MVMODS"
    echo ' '
    echo '#  Compiler options'
    echo ' '
    echo 'FORTRAN = '$FORTRAN
    echo 'BASIC = '$BASIC
    echo 'MODULES = '$MODTMP
    echo 'OPTIMIZATION = '$OPTIMIZATION
    echo 'NOOPTIMIZATION = '$NOOPTIMIZATION
    echo 'DEBUG = '$DEBUG
    echo 'OPENMP = '$OPENMP
    echo 'F77 = '$F77
    echo 'F90 = '$F90
    echo 'F95 = '$F95
    echo 'NOFMAIN = '$NOFMAIN
    echo 'USUAL = '$USUAL
    echo 'SPECIAL = '$SPECIAL
    echo 'F77SUFFIX = '$F77SUFFIX
    echo 'F95SUFFIX  = '$F95SUFFIX
    echo 'TIMER = '$TIMER
    echo 'NOT95 = '$NOT95
    echo 'NOT64 = '$NOT64
    echo ' '
    echo 'AMPLDIR   = '$AMPLLIBDIR
    echo 'CC        = '$CC
    echo 'CCBASIC   = '$CCBASIC
    echo 'CCISO     = '$CCISO
    echo 'CCONDEF   = '$CCONDEF
    echo 'CCDEBUG   = '$CCDEBUG
    echo ' '
    echo '#  Special flags'
    echo ' '
    echo ' '
    echo '#  Libraries'
    echo ' '
    echo 'BLAS = '$BLAS
    echo 'LAPACK = '$LAPACK
    echo 'CUTERUSED = '
    echo ' '
    echo '#  Shell used'
    echo ' '
    echo 'BINSHELL = '$BINSHELL
    echo ' '
    echo '#  Set directories for optional packages'
    echo ' '
    echo 'include $(SIFDECODE)/src/makedefs/packages'
    echo ' '
    echo '#  Body of makefile'
    echo ' '
    echo 'include $(PWD)/makemaster'
} > $SIFDECODE/makefiles/$MYARCH

# compile the selected packages
cd $SIFDECODE/src/ || exit 1

echo -e "\nInstalling the double precision version"
OPTIONS="-s -f $SIFDECODE/makefiles/$MYARCH"
MACROS="PRECIS=double PWD=$SIFDECODE/src SIFDECODE=$SIFDECODE"
echo " compiling in $SIFDECODE/src with the command"
echo " $MAKE $OPTIONS all"
if ! $MAKE $OPTIONS all $MACROS; then
    exit 1
fi

# install cutest
echo ' Installing CUTEst ...'
cd $CUTEST || exit 1

# create architecture-dependent object and module directories
OBJDIR=$CUTEST/objects/$MYARCH
MODDIR=$CUTEST/modules/$MYARCH
PKGDIR=$CUTEST/packages/$MYARCH
echo "$MACHINE ($OPSYS) $COMPUSED" > $CUTEST/versions/$MYARCH
if [[ ! -e $OBJDIR ]]; then
    $MKDIR $OBJDIR
    $MKDIR $OBJDIR/double $OBJDIR/single
else
    [[ ! -e $OBJDIR/double ]] && $MKDIR $OBJDIR/double
    [[ ! -e $OBJDIR/single ]] && $MKDIR $OBJDIR/single
fi
if [[ ! -e $MODDIR ]]; then
    $MKDIR $MODDIR
    $MKDIR $MODDIR/double $MODDIR/single
else
    [[ ! -e $MODDIR/double ]] && $MKDIR $MODDIR/double
    [[ ! -e $MODDIR/single ]] && $MKDIR $MODDIR/single
fi
[[ ! -e $PKGDIR ]] && $MKDIR $PKGDIR
[[ ! -e $PKGDIR/double ]] && $MKDIR $PKGDIR/double
[[ ! -e $PKGDIR/single ]] && $MKDIR $PKGDIR/single

#  write out the cutest/bin/sys file for this architecture
FFLAGS="$LIBCMD"' '`eval echo $MODCMD`' '"$F90"
{
    echo 'RM="'$RM'"'
    echo 'MAKE="'$MAKE'"'
    echo 'CAT="'$CAT'"'
    echo 'SED="'$SED'"'
    echo 'MV="'$MV'"'
    echo 'CP="'$CP'"'
    echo 'LS="'$LS'"'
    echo 'LN="'$LN'"'
    echo 'FORTRAN="'$FORTRAN'"'
    echo 'FFLAGS="'$FFLAGS' '$OPENMP'"'
    echo 'PROBFLAGS="'$FFLAGS' '$BASIC' '$OPTIMIZATION' '$F77' "'
    echo 'BLAS="'$BLAS'"'
    echo 'LAPACK="'$LAPACK'"'
} > $CUTEST/bin/sys/$MYARCH

# write out the cutest/makefile/ file for this architecture
MODTMP="$LIBCMD"' '`echo $MODCMD | $SED 's/MOD/(MOD)/g'`
{
    echo ' '
    echo '#  Architecture dependent makefile'
    echo '#  (automatically generated by install_cutest)'
    echo ' '
    echo 'VERSION = '$MYARCH
    echo ' '
    echo '#  Basic system commands'
    echo ' '
    echo 'CP = '$CP
    echo 'MV = '$MV
    echo 'RM = '$RM
    echo 'SED = '$SED
    echo 'GREP = '$GREP
    echo 'AR = '$AR
    echo 'ARREPFLAGS = '$ARREPFLAGS
    echo 'RANLIB = '$RANLIB
    echo ' '
    echo '#  Directory for binaries'
    echo ' '
    echo 'PRECIS = double'
    echo 'OBJ = $(CUTEST)/objects/$(VERSION)/$(PRECIS)'
    echo 'OBJS = $(CUTEST)/objects/$(VERSION)/single'
    echo 'OBJD = $(CUTEST)/objects/$(VERSION)/double'
    echo 'MOD = $(CUTEST)/modules/$(VERSION)/$(PRECIS)'
    echo 'SEDS = $(CUTEST)/seds/$(PRECIS).sed'
    echo 'MVMODS = '"$MVMODS"
    echo ' '
    echo '#  Compiler options'
    echo ' '
    echo 'FORTRAN = '$FORTRAN
    echo 'BASIC = '$BASIC
    echo 'MODULES = '$MODTMP
    echo 'OPTIMIZATION = '$OPTIMIZATION
    echo 'NOOPTIMIZATION = '$NOOPTIMIZATION
    echo 'DEBUG = '$DEBUG
    echo 'OPENMP = '$OPENMP
    echo 'F77 = '$F77
    echo 'F90 = '$F90
    echo 'F95 = '$F95
    echo 'NOFMAIN = '$NOFMAIN
    echo 'USUAL = '$USUAL
    echo 'SPECIAL = '$SPECIAL
    echo 'F77SUFFIX = '$F77SUFFIX
    echo 'F95SUFFIX  = '$F95SUFFIX
    echo 'TIMER = '$TIMER
    echo 'NOT95 = '$NOT95
    echo 'NOT64 = '$NOT64
    echo ' '
    echo 'AMPLDIR   = '$AMPLLIBDIR
    echo 'CC        = '$CC
    echo 'CCBASIC   = '$CCBASIC
    echo 'CCISO     = '$CCISO
    echo 'CCONDEF   = '$CCONDEF
    echo 'CCDEBUG   = '$CCDEBUG
    echo 'CCFFLAGS  = '$CCFFLAGS
    echo ' '
    echo '#  Special flags'
    echo ' '
    echo ' '
    echo '#  Libraries'
    echo ' '
    echo 'BLAS = '$BLAS
    echo 'LAPACK = '$LAPACK
    echo 'CUTESTUSED = '
    echo ' '
    echo '#  Shell used'
    echo ' '
    echo 'BINSHELL = '$BINSHELL
    echo ' '
    echo '#  Set directories for optional packages'
    echo ' '
    echo 'include $(CUTEST)/src/makedefs/packages'
    echo ' '
    echo '#  Body of makefile'
    echo ' '
    echo 'include $(PWD)/makemaster'
} > $CUTEST/makefiles/$MYARCH

# compile the selected packages
cd $CUTEST/src/ || exit 1
OPTIONS="-s -f $CUTEST/makefiles/$MYARCH"
PREC='double'
echo -e "\n Installing the $PREC precision version"
MACROS="PRECIS=$PREC PWD=$CUTEST/src CUTEST=$CUTEST"
echo " compiling in $CUTEST/src with the command"
echo " $MAKE $OPTIONS all"
if ! $MAKE $OPTIONS all $MACROS; then
    exit 1
fi
echo 'CUTEst successfully installed'

cd $TOPDIR || exit 1
