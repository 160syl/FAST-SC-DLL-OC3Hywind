MODULE SysSubs

   ! This module contains routines with system-specific logic and references.
   ! It also contains standard (but not system-specific) routines it uses.


   ! It contains the following routines:

   !     FUNCTION    COMMAND_ARGUMENT_COUNT()
   !     SUBROUTINE  FileSize ( FileName, Size )
   !     SUBROUTINE  FindLine ( Str , MaxLen , StrEnd )
   !     SUBROUTINE  FlushOut ( Unit )
   !     SUBROUTINE  Get_Arg ( Arg_Num , Arg , Error )                                      ! Please use GET_COMMAND_ARGUMENT() instead.
   !     SUBROUTINE  Get_Arg_Num ( Arg_Num )                                                ! Please use COMMAND_ARGUMENT_COUNT() instead.
   !     SUBROUTINE  GET_COMMAND ( Command, Length, Status )
   !     SUBROUTINE  GET_COMMAND_ARGUMENT ( Number, Value, Length, Status )
   !     SUBROUTINE  GET_CWD( DirName, Status )
   !     FUNCTION    Get_Env( EnvVar )                                                      ! Please use GET_ENVIRONMENT_VARIABLE() instead.
   !     FUNCTION    GET_ENVIRONMENT_VARIABLE( Name, Value, Length, Status, Trim_Name )
   !     FUNCTION    Is_NaN( DblNum )
   !     SUBROUTINE  OpenBinFile ( Un, OutFile, RecLen, Error )
   !     SUBROUTINE  OpenBinInpFile( Un, InFile, Error )
   !     SUBROUTINE  OpenUnfInpBEFile ( Un, InFile, RecLen, Error )
   !     SUBROUTINE  OpenCon
   !     SUBROUTINE  ProgExit ( StatCode )
   !     SUBROUTINE  UsrAlarm
   !     FUNCTION    UserTime()                                                             ! Removed: Replace by F95 intrinsic, CPU_TIME().
   !     SUBROUTINE  WrNR ( Str )
   !     SUBROUTINE  WrOver ( Str )
   !     SUBROUTINE  WrScr ( Str )




   USE                             Precision

   IMPLICIT                        NONE


!=======================================================================


   INTEGER                      :: ConRecL  = 120                               ! The record length for console output.
   INTEGER                      :: CU       = 7                                 ! The I/O unit for the console.
   INTEGER                      :: NL_Len   = 2                                 ! The number of characters used for a new line.

   CHARACTER(10)                :: Endian   = 'BIG_ENDIAN'                      ! The internal format of numbers.
   CHARACTER( 1)                :: PathSep  = '\'                               ! The path separater.
   CHARACTER( 1)                :: SwChar   = '/'                               ! The switch character for command-line options.
   CHARACTER( 6)                :: UnfForm  = 'BINARY'                          ! The string to specify unformatted I/O files.


CONTAINS

!=======================================================================
   FUNCTION COMMAND_ARGUMENT_COUNT()


      ! This routine returns the number of argumenta entered on the command line..

      ! Note: This routine will be available intrinsically in Fortran 2000.



      ! Function declaration.

   INTEGER                      :: COMMAND_ARGUMENT_COUNT                       ! This function.  The command line.



      ! Determine the mumber of arguments.  Load the program name into the result.

   COMMAND_ARGUMENT_COUNT = 0


   RETURN
   END FUNCTION COMMAND_ARGUMENT_COUNT ! ()
!=======================================================================
   SUBROUTINE FileSize ( FileName, Size )


      ! This routine calls the routine FSTAT to obtain the size
      ! of the specify file or returns -1 on error.


   USE                             IFPORT


      ! Argument declarations:

   INTEGER, INTENT(OUT)         :: Size

   CHARACTER(*), INTENT(IN)     :: FileName


      ! Local declarations:

   INTEGER                      :: IOS
   INTEGER                      :: StatArray(12)
   INTEGER                      :: Status
   INTEGER                      :: Unit

!bjj: Unit is not defined!!!!....

      ! Open file.  Determine its size.

   OPEN( Unit, FILE=TRIM( FileName ), STATUS='OLD', FORM='FORMATTED', IOSTAT=IOS, ACTION='READ' )

   IF ( IOS /= 0 )  THEN

      Size = -1

   ELSE

      Status = FSTAT( Unit , StatArray )

      IF ( Status /= 0 ) THEN
         Size = -1
      ELSE
        Size = StatArray(8)
      END IF

   END IF


   RETURN
   END SUBROUTINE FileSize ! ( FileName, Size )
!=======================================================================
   SUBROUTINE FindLine ( Str , MaxLen , StrEnd )


      ! This routine finds one line of text with a maximum length of MaxLen from the Str.
      ! It tries to break the line at a blank.

      ! This routine isn't system specific, but it is called by WrScr(), which is, so it must be here.


   IMPLICIT                        NONE


      ! Argument declarations:

   INTEGER, INTENT(IN)          :: MaxLen                                       ! The maximum length of the string.
   INTEGER, INTENT(OUT)         :: StrEnd                                       ! The location of the end of the string.

   CHARACTER(*), INTENT(IN)     :: Str                                          ! The string to search.


      ! Local declarations:

   INTEGER         IC



   StrEnd = MaxLen

   IF ( LEN_TRIM( Str ) > MaxLen )  THEN

      IC = INDEX( Str(1:MaxLen), ' ', BACK = .TRUE. ) ! Find the last space in the line

      IF ( IC > 1 ) THEN ! We don't want to return just one character that's a space, or do we?

         StrEnd = IC-1    ! StrEnd > 0
         DO WHILE ( Str(StrEnd:StrEnd) == ' ' )
            StrEnd = StrEnd - 1
            IF ( StrEnd <= 0 ) THEN  ! This occurs if everything before IC is a space
               StrEnd = IC
               EXIT
            ENDIF
         ENDDO

      ENDIF ! IC > 1

   ENDIF ! LEN_TRIM( Str ) > MaxLen


   RETURN
   END SUBROUTINE FindLine ! ( Str , MaxLen , StrEnd )
!=======================================================================
   SUBROUTINE FlushOut ( Unit )


      ! This subroutine flushes the buffer on the specified Unit.
      ! It is especially useful when printing "running..." type messages.


   USE                             IFPORT


      ! Argument declarations:

   INTEGER, INTENT(IN)          :: Unit                                         ! The maximum length of the string.



   CALL FLUSH ( Unit )


   RETURN
   END SUBROUTINE FlushOut ! ( Unit )
!=======================================================================
   SUBROUTINE Get_Arg ( Arg_Num , Arg , Error )


      ! This routine gets Arg_Num'th argument from the command line.

   ! Note: The functionality in this routine was replaced by GET_COMMAND_ARGUMENT(), which will be available intrinsically in Fortran 2000.



      ! Argument declarations.

   INTEGER, INTENT(IN)          :: Arg_Num                                      ! The argument number to get.

   LOGICAL, INTENT(OUT)         :: Error                                        ! The Error flag returned to the calling program.

   CHARACTER(*), INTENT(OUT)    :: Arg                                          ! The argument string returned to the calling program.


      ! Local declarations.

   INTEGER                      :: Status                                       ! The status of the attempt to get an argument.



   Arg = ''


   IF ( LEN_TRIM( Arg ) > 0 )  THEN
      Error = .FALSE.
   ELSE
      Error = .TRUE.
   END IF


   RETURN
   END SUBROUTINE Get_Arg ! ( Arg_Num , Arg , Error )
!=======================================================================
   SUBROUTINE Get_Arg_Num ( Arg_Num )


      ! This routine gets the number of command line arguments.

   ! Note: The functionality in this routine was replaced by COMMAND_ARGUMENT_COUNT(), which will be available intrinsically in Fortran 2000.



      ! Argument declarations.

   INTEGER, INTENT(OUT)         :: Arg_Num                                      ! The argument to get from the command line.


   Arg_Num = 0


   RETURN
   END SUBROUTINE Get_Arg_Num ! ( Arg_Num )
!=======================================================================
   SUBROUTINE GET_COMMAND ( Command, Length, Status )


      ! This routine returns the string associated with the full command line.
      ! It tries as best it can to mimic the Fortran 2000 intrinsic subroutine by the same name.



      ! Argument declarations.

   INTEGER, OPTIONAL, INTENT(OUT)      :: Length                                ! The length of the value of the environment variable.
   INTEGER, OPTIONAL, INTENT(OUT)      :: Status                                ! The status indication what happened.

   CHARACTER(*), OPTIONAL, INTENT(OUT) :: Command                               ! The command line.


      ! Local parameter declarations.

   INTEGER, PARAMETER                  :: MaxLen = 500                          ! The maximum length permitted for an environment variable value.


      ! Local declarations.

   INTEGER                             :: CallStat                              ! Status of the call.
   INTEGER                             :: IArg                                  ! Argument index.

   CHARACTER(MaxLen)                   :: Arg                                   ! The current argument.
   CHARACTER(MaxLen)                   :: ReturnVal                             ! The value that will be returned.


   ReturnVal = ''

   IF ( PRESENT( Command ) )  Command = ReturnVal
   IF ( PRESENT( Length  ) )  Length  = LEN_TRIM( ReturnVal )
   IF ( PRESENT( Status  ) )  Status  = 0


   RETURN
   END SUBROUTINE GET_COMMAND ! ( Command, Length, Status )
!=======================================================================
   SUBROUTINE GET_COMMAND_ARGUMENT ( Number, Value, Length, Status )


      ! This routine returns the string associated with the Numberth command-line argument.
      ! It tries as best it can to mimic the Fortran 2000 intrinsic function by the same name.



      ! Argument declarations.

   INTEGER, OPTIONAL, INTENT(OUT)      :: Length                                ! The length of the value of the environment variable.
   INTEGER, INTENT(IN)                 :: Number                                ! The number of the argument desired.
   INTEGER, OPTIONAL, INTENT(OUT)      :: Status                                ! The status indication what happened.

   CHARACTER(*), OPTIONAL, INTENT(OUT) :: Value                                 ! The command line argument.


      ! Local parameter declarations.

   INTEGER, PARAMETER                  :: MaxLen = 500                          ! The maximum length permitted for an environment variable value.


      ! Local declarations.

   INTEGER                             :: CallStat                              ! The status of the intrinsic call.

   CHARACTER(MaxLen)                   :: ReturnVal                             ! The value that will be returned.



      ! Get the argument.

   ReturnVal = ''

      ! Load up the return values.

   IF ( PRESENT( Value  ) )  Value  = ReturnVal
   IF ( PRESENT( Length ) )  Length = LEN_TRIM( ReturnVal )
   IF ( PRESENT( Status ) )  Status = CallStat


   RETURN
   END SUBROUTINE GET_COMMAND_ARGUMENT ! ( Number, Value, Length, Status )
!=======================================================================
   SUBROUTINE Get_CWD ( DirName, Status )


      ! This routine retrieves the path of the current working directory.


   USE                             IFPORT

   IMPLICIT                        NONE


      ! Passed variables.

   CHARACTER(*), INTENT(OUT)    :: DirName                                         ! A CHARACTER string containing the path of the current working directory.
   INTEGER,      INTENT(OUT)    :: Status                                          ! Status returned by the call to a portability routine.


   Status = GETCWD ( DirName )

   RETURN
   END SUBROUTINE Get_CWD
!=======================================================================
   FUNCTION Get_Env( EnvVar )


      ! This routine returns the string associated with the EnvVar environment variable in the OS.
      ! It returns the null string of the variable is not found.

   ! Note: The functionality in this routine was replaced by GET_ENVIRONMENT_VARIABLE(), which will be available intrinsically in Fortran 2000.


   USE                             IFPORT


      ! Function declaration.

   CHARACTER(500)               :: Get_Env                                      ! This function.  The value of the environment variable.


      ! Argument declarations.

   CHARACTER(*), INTENT(IN)     :: EnvVar                                       ! The environment variable to look up.



   CALL GetEnv ( EnvVar, Get_Env )


   RETURN
   END FUNCTION Get_Env ! ( EnvVar )
!=======================================================================
   FUNCTION GET_ENVIRONMENT_VARIABLE( Name, Value, Length, Status, Trim_Name )


      ! This routine returns the string associated with the Name environment variable in the OS.
      ! It tries as best it can to mimic the Fortran 2000 intrinsic function by the same name.


   USE                                    IFPORT


      ! Argument declarations.

   INTEGER, OPTIONAL, INTENT(OUT)      :: Length                                ! The length of the value of the environment variable.
   INTEGER, OPTIONAL, INTENT(OUT)      :: Status                                ! The status indication what happened.

   LOGICAL, OPTIONAL, INTENT(IN)       :: Trim_Name                             ! Treat trailing blanks in Name as significant if true.

   CHARACTER(*), INTENT(IN)            :: Name                                  ! The environment variable to look up.
   CHARACTER(*), OPTIONAL, INTENT(OUT) :: Value                                 ! The found value of the environment variable, Name.


      ! Local parameter declarations.

   INTEGER, PARAMETER                  :: MaxLen = 500                          ! The maximum length permitted for an environment variable value.


      ! Function declaration.

   CHARACTER(MaxLen)                   :: GET_ENVIRONMENT_VARIABLE              ! This function.  The value of the environment variable.


      ! Local declarations.

   CHARACTER(MaxLen)                   :: ReturnVal                             ! The value that will be returned.



      ! When asking the OS about the variable, trim the name unless Trim_Name is false.

   IF ( PRESENT( Trim_Name ) )  THEN
      IF ( Trim_Name )  THEN
         CALL GetEnv ( TRIM( Name ), ReturnVal )
      ELSE
         CALL GetEnv ( Name, ReturnVal )
      END IF
   ELSE
      CALL GetEnv ( TRIM( Name ), ReturnVal )
   END IF

   IF ( PRESENT( Value ) )  Value = ReturnVal

   IF ( PRESENT( Length ) )  Length = LEN_TRIM( ReturnVal )


      ! If requested, set the status of the OS request.

      ! Because the VF-specific GetEnv() is less capable than the Fortran 2000 intrinsic, we can't distinguish
      ! between a variable whose value is all blanks and one that is not set.

   IF ( PRESENT( Status ) )  THEN
      IF ( LEN_TRIM( ReturnVal ) == 0 )  THEN
         Status = 1
      ELSE
         Status = 0
      END IF
   END IF

   GET_ENVIRONMENT_VARIABLE = ReturnVal


   RETURN
   END FUNCTION GET_ENVIRONMENT_VARIABLE ! ( Name, Value, Length, Status, Trim_Name )
!=======================================================================
   FUNCTION Is_NaN( DblNum )


      ! This routine determines if a REAL(DbKi) variable holds a proper number.


   USE                             IFPORT


      ! Argument declarations.

   REAL(DbKi), INTENT(IN)       :: DblNum


      ! Function declaration.

   LOGICAL                      :: Is_Nan



   Is_NaN = IsNaN( DblNum )


   RETURN
   END FUNCTION Is_NaN ! ( DblNum )
!=======================================================================
   SUBROUTINE OpenBinFile ( Un, OutFile, RecLen, Error )


      ! This routine opens a binary output file.


      ! Argument declarations.

   INTEGER, INTENT(IN)          :: Un                                           ! Logical unit for the output file.
   INTEGER, INTENT(IN)          :: RecLen                                       ! Length of binary record.

   LOGICAL, INTENT(OUT)         :: Error                                        ! Flag to indicate the open failed.

   CHARACTER(*), INTENT(IN)     :: OutFile                                      ! Name of the output file.


      ! Local declarations.

   INTEGER                      :: IOS                                          ! I/O status of OPEN.



      ! Open output file.  Make sure it worked.

   OPEN( Un, FILE=TRIM( OutFile ), STATUS='UNKNOWN', FORM='BINARY' , ACCESS='SEQUENTIAL', RECL=RecLen , IOSTAT=IOS )

   IF ( IOS /= 0 )  THEN
      Error = .TRUE.
   ELSE
      Error = .FALSE.
   END IF


   RETURN
   END SUBROUTINE OpenBinFile ! ( Un, OutFile, RecLen, Error )
!=======================================================================
   SUBROUTINE OpenBinInpFile ( Un, InFile, Error )


      ! This routine opens a binary input file.

   IMPLICIT                        NONE



      ! Argument declarations.

   INTEGER, INTENT(IN)          :: Un                                           ! Logical unit for the input file.

   CHARACTER(*), INTENT(IN)     :: InFile                                       ! Name of the input file.

   LOGICAL, INTENT(OUT)         :: Error                                        ! Flag to indicate the open failed.


      ! Local declarations.

   INTEGER                      :: IOS                                          ! I/O status of OPEN.

      ! NOTE: Do not explicitly declare the precision of this variable [as in
      !       LOGICAL(1)] so that the statements using this variable work with
      !       any compiler:


      ! Open input file.  Make sure it worked.

   OPEN( Un, FILE=TRIM( InFile ), STATUS='OLD', FORM='BINARY', IOSTAT=IOS, ACTION='READ' )

   IF ( IOS /= 0 )  THEN
      Error = .TRUE.
   ELSE
      Error = .FALSE.
   END IF


   RETURN
   END SUBROUTINE OpenBinInpFile
!=======================================================================
   SUBROUTINE OpenUnfInpBEFile ( Un, InFile, RecLen, Error )


      ! This routine opens a binary input file with data stored in Big Endian format (created on a UNIX machine.)
      ! Data are stored in RecLen-byte records.

   IMPLICIT                        NONE



      ! Argument declarations.

   INTEGER, INTENT(IN)          :: Un                                           ! Logical unit for the input file.

   CHARACTER(*), INTENT(IN)     :: InFile                                       ! Name of the input file.

   INTEGER, INTENT(IN)          :: RecLen                                       ! Size of records in the input file, in bytes. 

   LOGICAL, INTENT(OUT)         :: Error                                        ! Flag to indicate the open failed.


      ! Local declarations.

   INTEGER                      :: IOS                                          ! I/O status of OPEN.



      ! Open input file.  Make sure it worked.

   ! The non-standard CONVERT keyword allows us to read UNIX binary files, whose bytes are in reverse order (i.e., stored in BIG ENDIAN format).
   
   ! NOTE: using RecLen in bytes requires using the /assume:byterecl compiler option!

   OPEN ( Un, FILE=TRIM( InFile ), STATUS='OLD', FORM='UNFORMATTED', ACCESS='DIRECT', RECL=RecLen, IOSTAT=IOS, &
                   ACTION='READ', CONVERT='BIG_ENDIAN' )                         ! Use this for PC systems.
!                  ACTION='READ'  )                                              ! Use this for UNIX systems.


   IF ( IOS /= 0 )  THEN
      Error = .TRUE.
   ELSE
      Error = .FALSE.
   END IF


   RETURN
   END SUBROUTINE OpenUnfInpBEFile
!=======================================================================
   SUBROUTINE OpenCon


      ! This routine opens the console for standard output.




   RETURN
   END SUBROUTINE OpenCon
!=======================================================================
   SUBROUTINE ProgExit ( StatCode )


      ! This routine stops the program.  If the compiler supports the EXIT routine,
      ! pass the program status to it.  Otherwise, do a STOP.


      ! Argument declarations.

   INTEGER, INTENT(IN)          :: StatCode                                      ! The status code to pass to the OS.

   EXTERNAL                     :: mexErrMsgTxt                                  ! A MATLAB subroutine


      ! Close the program      
   IF ( StatCode == 0 ) THEN        ! A normal stop
      CALL mexErrMsgTxt( 'Normal stop.'//ACHAR(10) )    !I really don't want to call this function.... is there another to stop fortran execution without closing Matlab?
   ELSE                             ! an error occurred
      CALL mexErrMsgTxt( 'Closing program.'//ACHAR(10) ) 
   ENDIF


   RETURN
   END SUBROUTINE ProgExit ! ( StatCode )
!=======================================================================
   SUBROUTINE UsrAlarm


      ! This routine generates an alarm to warn the user that something went wrong.


   RETURN
   END SUBROUTINE UsrAlarm
!=======================================================================
!   FUNCTION UserTime()
!
!
!      ! This function returns the user CPU time.
!
!      ! The functionality of this routine was replaced by the F95 intrinsic, CPU_TIME().
!
!
!      ! Passed variables.
!
!   REAL(4)                      :: UserTime                                        ! User CPU time.
!
!
!      ! Local variables.
!
!   REAL(4)                      :: TimeAry (2)                                     ! TimeAry(1): User CPU time, TimeAry(2): System CPU time.
!   REAL(4)                      :: TotTime                                         ! User CPU time plus system CPU time.
!
!
!
!
!   TotTime  = DTIME( TimeAry )
!   UserTime = TimeAry(1)
!
!
!   RETURN
!   END FUNCTION UserTime
!=======================================================================
   SUBROUTINE WrNR ( Str )


      ! This routine writes out a string to the screen without following it with a new line.


      ! Argument declarations.

   CHARACTER(*), INTENT(IN)     :: Str                                          ! The string to write to the screen.
   
   INTEGER                      :: Stat                                         ! Number of characters printed
   INTEGER, EXTERNAL            :: mexPrintF                                    ! Matlab function to print to the command window
   
   Stat = mexPrintF( ' '//TRIM(Str) ) 


   RETURN
   END SUBROUTINE WrNR ! ( Str )
!=======================================================================
   SUBROUTINE WrOver ( Str )


      ! This routine writes out a string that overwrites the previous line


      ! Argument declarations.

   CHARACTER(*), INTENT(IN)     :: Str                                          ! The string to write to the screen.

   INTEGER                      :: Stat
   INTEGER, EXTERNAL            :: mexPrintF                                    ! Matlab function to print to the command window


   CALL WrScr( Str )


   RETURN
   END SUBROUTINE WrOver ! ( Str )
!=======================================================================
   SUBROUTINE WrScr ( Str )


      ! This routine writes out a string to the screen.


   IMPLICIT                        NONE


      ! Argument declarations.

   CHARACTER(*), INTENT(IN)     :: Str                                          ! The string to write to the screen.
   CHARACTER(200)               :: Str2
   
      ! Local declarations.

   INTEGER                      :: Beg                                          ! The beginning of the next line of text.
   INTEGER                      :: Indent                                       ! The amunt to be indented.
   INTEGER                      :: LStr                                         ! The length of the remaining portion of the string.
   INTEGER                      :: MaxLen                                       ! Maximum number of columns to be written to the screen.

   INTEGER, EXTERNAL            :: mexPrintF                                    ! Matlab function to print to the command window
   INTEGER                      :: Stat                                         ! Number of characters printed to the screen
   CHARACTER(10)                :: Frm                                          ! Format specifier for the output.


!   EXTERNAL                     :: mexPrintf                                    ! A MATLAB function

      ! Find the amount of indent.  Create format.

   MaxLen = 98
   Indent = LEN_TRIM( Str ) - LEN_TRIM( ADJUSTL( Str ) )
   MaxLen = MaxLen - Indent
   IF ( Indent > 0 )  THEN
      Frm    = '(1X,  X,A)'
      WRITE (Frm(5:6),'(I2)')  Indent
   ELSE
      Frm    = '(1X,A)'
   END IF


   !  Break long messages into multiple lines.

   Beg  = Indent + 1
   LStr = LEN_TRIM( Str(Beg:) )

   DO WHILE ( Lstr > MaxLen )

      CALL FindLine ( Str(Beg:) , MaxLen , LStr )

      WRITE (Str2,Frm)  ADJUSTL( Str(Beg:Beg+LStr-1) )
      Stat = mexPrintf(TRIM(Str2)//ACHAR(10)) 
      !call mexEvalString("drawnow;");  ! !bjj: may have to call this to dump string to the screen immediately.


      Beg = Beg + LStr

         !If we have a space at the beginning of the string, let's get rid of it

      DO WHILE ( Beg < LEN_TRIM( Str ) .AND. Str(Beg:Beg) == ' ' )
         Beg = Beg + 1
      ENDDO

      LStr = LEN_TRIM( Str(Beg:) )

   ENDDO

   IF ( LStr > 0 ) THEN
      WRITE (Str2,Frm)  ADJUSTL( Str(Beg:Beg+LStr-1) )
   ELSE
      Str2=''
   END IF      
   Stat = mexPrintf(TRIM(Str2)//ACHAR(10))   


   RETURN
   END SUBROUTINE WrScr ! ( Str )
!=======================================================================

END MODULE SysSubs
