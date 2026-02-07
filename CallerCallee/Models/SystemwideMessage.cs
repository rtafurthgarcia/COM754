using CommunityToolkit.Mvvm.Messaging.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CallerCallee.Models
{
    public static class SystemwideMessage
    {
        public class CallInitiated(PhoneCall call) : ValueChangedMessage<PhoneCall>(call)
        {
        }

        public class CallCompleted(PhoneCall call) : ValueChangedMessage<PhoneCall>(call)
        {
        }

        public class CallInterrupted(PhoneCall call) : ValueChangedMessage<PhoneCall>(call)
        {
        }

        public class NextTurnBeingPlayed(PhoneCall call) : ValueChangedMessage<PhoneCall>(call)
        {
        }

        public class DetectionResultReceived(Classifications detectionResult) : ValueChangedMessage<Classifications>(detectionResult)
        {
        }
        public class EndOfAnalysis(Guid guid) : ValueChangedMessage<Guid>(guid)
        {
        }
    }
}
