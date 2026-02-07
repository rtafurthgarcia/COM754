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
        Callee,
        System
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
        Completed,
        Failed,
        Ongoing,
        Analysing,
    }
}
