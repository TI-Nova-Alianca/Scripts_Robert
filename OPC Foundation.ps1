/*
Opc.Da.Server scadaServer = null;
List<Opc.Da.Item> scadaItems = null;
Opc.Da.Subscription scadaSubscription = null;

string scadaUrl = string.Format("opcda://{0}/{1}", hostname,
                                                   opcServerVendor);

scadaServer = new Opc.Da.Server(new OpcCom.Factory(), new Opc.URL(scadaUrl));
scadaServer.Connect();

var scadaItems = new List<Opc.Da.Item>(); // I'm using a List<T>, but cast back to a simple array using ToArray();

// Repeat this next part for all the items you need to subscribe
Opc.Da.Item item = new Opc.Da.Item();
item.ItemName = TagPath; // Where TagPath is something like device.channel.tag001;
item.ClientHandle = handle; // handle is up to you, but i use a logical name for it
item.Active = true;
item.ActiveSpecified = true;

scadaItems.Add(item);

Opc.Da.SubscriptionState subscriptionState = new Opc.Da.SubscriptionState();
subscriptionState.Active = true;
subscriptionState.UpdateRate = 40;
subscriptionState.Deadband = 0;

scadaSubscription = scadaSubscription ?? (Opc.Da.Subscription)scadaServer.CreateSubscription(subscriptionState);

Opc.Da.ItemResult[] result = scadaSubscription.AddItems(scadaItems.ToArray());
for (int i = 0; i < result.Length; i++)
    scadaItems[i].ServerHandle = result[i].ServerHandle;

scadaSubscription.DataChanged += new Opc.Da.DataChangedEventHandler(OnDataChange);
scadaSubscription.State.Active = true;
*/