import { useState } from 'react'
import './App.css'

const AMPERAGE_LIST = [10, 15, 20, 30, 40, 50, 60];
type ResponseData = {
  provider: {
    id: number;
    name: string;
  },
  plan: {
    id: number;
    name: string;
    price: number;
  },
}

function App() {
  const [electricityUsageKwh, setElectricityUsageKwh] = useState<number>(0);
  const [amperage, setAmperage] = useState<number | undefined>(undefined);
  const [prices, setPrices] = useState<ResponseData[]>([]);

  const requestCalcPrices = async () => {
    if (amperage === undefined) return;
    try {
      const response = await fetch(`${import.meta.env.VITE_API_URL}/api/electricity/calculate`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          amperage,
          electricity_usage_kwh: electricityUsageKwh,
        }),
      });

      if (!response.ok) {
        throw new Error('Network response was not ok');
      }

      const data: { data: ResponseData[] } = await response.json();
      setPrices(data.data);
    } catch (error) {
      console.error('There was a problem with the fetch operation:', error);
    }
  };

   return (
    <>
      <h1>電力料金計算</h1>
      <div>
        <div>
          <label htmlFor="amperage-select">アンペア数</label>
          <select name="amperage" id="amperage-select" onChange={(event) => {
            if (!event.target.value) {
              setAmperage(undefined);
            } else {
              setAmperage(parseInt(event.target.value, 10));
            }
          }}>
            <option value="">未選択</option>
            {AMPERAGE_LIST.map((value) => (
              <option key={value} value={value}>{value}</option>
            ))}
          </select>
        </div>
        <div>
          <label htmlFor="amperage-select">電気使用量(kwh)</label>
          <input
              type="text"
              maxLength={4}
              value={electricityUsageKwh}
              onChange={(event) => {
                const found = event.target.value.match(/\d/g)
                const text = found ? found.join('') : '';
                setElectricityUsageKwh(parseInt(text.length ? text : '0', 10))
              }}
          />
        </div>
        <div>
          <button onClick={requestCalcPrices} disabled={amperage == undefined}>計算</button>
        </div>
      </div>

      <div>
        {prices.map((price) => {
          return (
            <div key={price.plan.id}>
              <h2>{price.provider.name}</h2>
              <span>{price.plan.name}</span><span>{price.plan.price}円</span>
            </div>
          );
        })}
      </div>
    </>
    )
  }

export default App