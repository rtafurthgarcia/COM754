using Azure.Communication.Calling.WindowsClient;
using NAudio.Wave;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text.RegularExpressions;
using Windows.Security.Authentication.Web.Core;

namespace CallerCallee.Services
{
    public sealed partial class AudioService
    {
        [Serializable]
        public class VirtualMicrophoneNotFound : Exception
        {
            public VirtualMicrophoneNotFound()
            { }

            public VirtualMicrophoneNotFound(string message)
                : base(message)
            { }

            public VirtualMicrophoneNotFound(string message, Exception innerException)
                : base(message, innerException)
            { }
        }

        private struct InternalPlayer(ref WaveOutEvent WaveOutEvent, ref AudioFileReader AudioFileReader)
        {
            public WaveOutEvent waveOutEvent = WaveOutEvent;
            public AudioFileReader audioFileReader = AudioFileReader;
        }

        private readonly ConcurrentDictionary<int, InternalPlayer> playingAudios = new();
        private readonly ConcurrentStack<int> availableDevices = new();
        private static readonly Regex regex = CableRegex();

        public AudioService() {

            Enumerable
                .Range(0, WaveOut.DeviceCount)
                .Where(i => regex.IsMatch(WaveOut.GetCapabilities(i).ProductName))
                .ToList()
                .ForEach(availableDevices.Push);

            if (availableDevices.IsEmpty)
            {
                throw new VirtualMicrophoneNotFound("VB-Cable virtual microphones not detected. Make sure the drivers are installed and check the project's documentation.");
            }
        }

        public static int CountAvailableDevices()
        {
            var count = Enumerable
                .Range(0, WaveOut.DeviceCount)
                .Where(i => regex.IsMatch(WaveOut.GetCapabilities(i).ProductName))
                .Count();

            if (count == 0)
            {
                throw new VirtualMicrophoneNotFound("VB-Cable virtual microphones not detected. Make sure the drivers are installed and check the project's documentation.");
            }

            return count;
        }

        public static AudioDeviceDetails FindEquivalent(int deviceNumber, List<AudioDeviceDetails> possibleDevices)
        {
            var possibleName = WaveOut.GetCapabilities(deviceNumber).ProductName[..7];

            var result = possibleDevices.Find(i => i.Name[..7].Equals(possibleName));
            return result ?? throw new Exception("Couldn't find the corresponding microphone for your virtual speaker. Make sure the drivers are installed and check the project's documentation.");
        }

        public bool GetAvailableDevice(out int? deviceNunber)
        {
            var succeeded = availableDevices.TryPop(out int newDeviceNumber);

            if (succeeded) 
            { 
                deviceNunber = newDeviceNumber;
            }
            else
            {
                deviceNunber = null;
            }


            return succeeded;
        }

        public TimeSpan PlayAudioFile(int deviceToPlayOn, string audioFilePath, EventHandler<StoppedEventArgs> eventHandler)
        {
            //Debug.WriteLine($"Device {WaveOut.GetCapabilities(deviceToPlayOn).ProductName } used for playing.");

            var outputDevice = new WaveOutEvent() { DeviceNumber = deviceToPlayOn };
            outputDevice.PlaybackStopped += eventHandler;
            var audioFile = new AudioFileReader(@audioFilePath);
            outputDevice.Init(audioFile);
            playingAudios[deviceToPlayOn] = new (ref outputDevice, ref audioFile);
            outputDevice.Play();

            return audioFile.TotalTime;
        }

        public bool TryFreeDevice(int deviceNumber) 
        {
            var succeeded = playingAudios.TryRemove(deviceNumber, out InternalPlayer internalPlayer);
            if (succeeded)
            {
                internalPlayer.waveOutEvent.Dispose();
                internalPlayer.audioFileReader.Dispose();
                availableDevices.Push(deviceNumber);
            }

            return succeeded;

        }

        [GeneratedRegex(@"CABLE-[A-D] Input", RegexOptions.Compiled)]
        private static partial Regex CableRegex();
    }
}
