using CommunityToolkit.Mvvm.Messaging.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CallerCallee.Models
{
    public static class PhoneCallMessage
    {
        public class CallInitiated(PhoneCall call) : ValueChangedMessage<PhoneCall>(call)
        {
        }

        public class CallCompleted(PhoneCall call) : ValueChangedMessage<PhoneCall>(call)
        {
        }

        public class CallInterrupted(Exception exception) : ValueChangedMessage<Exception>(exception)
        {
        }

        public class NextTurnBeingPlayed(PhoneCall call) : ValueChangedMessage<PhoneCall>(call)
        {
        }
    }
}
