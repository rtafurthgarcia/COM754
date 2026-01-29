using Azure.Communication.Calling.WindowsClient;
using NAudio.Wave;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using Windows.Security.Authentication.Web.Core;

namespace CallerCallee.Services
{
    public sealed class AudioService
    {
        private struct InternalPlayer(ref WaveOutEvent WaveOutEvent, ref AudioFileReader AudioFileReader)
        {
            public WaveOutEvent waveOutEvent = WaveOutEvent;
            public AudioFileReader audioFileReader = AudioFileReader;
        }

        private readonly ConcurrentDictionary<int, InternalPlayer> playingAudios = new();
        private readonly ConcurrentStack<int> availableDevices = new();

        public AudioService() {
            Regex regex = new Regex(@"CABLE-[A-D] Input", RegexOptions.Compiled);

            Enumerable
                .Range(0, WaveOut.DeviceCount)
                .Where(i => regex.IsMatch(WaveOut.GetCapabilities(i).ProductName))
                .ToList()
                .ForEach(availableDevices.Push);

            if (availableDevices.IsEmpty)
            {
                throw new Exception("VB-Cable virtual microphones not detected. Make sure the drivers are installed and check the project's documentation.");
            }
        }

        public static AudioDeviceDetails FindEquivalent(int deviceNumber, List<AudioDeviceDetails> possibleDevices)
        {
            var possibleName = WaveOut.GetCapabilities(deviceNumber).ProductName.Substring(0, 7);

            var result = possibleDevices.Find(i => i.Name.Substring(0, 7).Equals(possibleName));
            if (result == null) {
                throw new Exception("Couldn't find the corresponding microphone for your virtual speaker. Make sure the drivers are installed and check the project's documentation.");
            }

            return result;
        }

        public int GetAvailableDevice()
        {
            var succeeded = availableDevices.TryPop(out int deviceNumber);
            if (succeeded)
            {
                return deviceNumber;
            }
            else
            {
                return -2; // -1 meaning "default device", which isnt what we want
                // -2 meaning there is available device at the moment
            }
        }

        public TimeSpan PlayAudioFile(int deviceToPlayOn, string audioFilePath, EventHandler<StoppedEventArgs> eventHandler)
        {
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
    }
}
