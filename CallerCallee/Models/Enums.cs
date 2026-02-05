using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CallerCallee.Models
{
    public enum Speaker
    {
        Caller,
        Callee
    }

    public enum EntryType
    {
        Call,
        TurnOfConversation,
    }

    public enum Flag
    {
        Fraud,
        Safe,
        Unknown
    }

    public enum State
    {
        Todo,
        Ongoing,
        WaitingForClassification,
        Completed,
        Failed,
    }
}
