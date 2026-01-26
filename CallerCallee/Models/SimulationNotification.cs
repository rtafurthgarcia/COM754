using CommunityToolkit.Mvvm.Messaging.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CallerCallee.Models
{
    public static class SimulationNotification
    {
        public class CallInitiated(DatasetEntry entry) : ValueChangedMessage<DatasetEntry>(entry)
        {
        }

        public class CallCompleted(DatasetEntry entry) : ValueChangedMessage<DatasetEntry>(entry)
        {
        }

        public class CallInterrupted(Exception exception) : ValueChangedMessage<Exception>(exception)
        {
        }

        public class TurnBeingPlayed(ParentChildDataset parentChild) : ValueChangedMessage<ParentChildDataset>(parentChild)
        {
        }
    }
}
