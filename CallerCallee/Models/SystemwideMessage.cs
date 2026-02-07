using CommunityToolkit.Mvvm.Messaging.Messages;
using System;

namespace CallerCallee.Models
{
    public static class SystemwideMessage
    {
        public class CallInitiated(PhoneCall call) : ValueChangedMessage<PhoneCall>(call)
        {
        }

        public class CallCompleted(int id) : ValueChangedMessage<int>(id)
        {
        }

        public class CallInterrupted(Exception exception) : ValueChangedMessage<Exception>(exception)
        {
        }

        public class NextTurnBeingPlayed((int, string) idThenIdTurn) : ValueChangedMessage<(int, string)>(idThenIdTurn)
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
