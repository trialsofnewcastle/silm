#include "nw_i0_plot"

int StartingConditional()
{
    int iResult;

    iResult =  GetPLocalInt(GetPCSpeaker(),"NW_STORY"+GetTag(OBJECT_SELF)) >= 10;
    return iResult;
}
